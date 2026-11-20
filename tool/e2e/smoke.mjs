// 1단계 화면 흐름 E2E 점검 (Playwright + Chromium, headless)
//
// 사용법:
//   flutter build web
//   python3 -m http.server 5556 -d build/web   (다른 터미널)
//   node tool/e2e/smoke.mjs [http://localhost:5556]
//
// - Flutter 웹은 캔버스로 그리므로 접근성(semantics) 트리를 켜서 버튼 이름으로 찾는다.
// - speechSynthesis.speak를 가로채 "무슨 말을 어떤 언어로 했는지" 기록한다 (소리는 안 남).
// - 스크린샷은 tool/e2e/screenshots/ 에 저장된다.
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const url = process.argv[2] ?? 'http://localhost:5556';
const shotDir = join(dirname(fileURLToPath(import.meta.url)), 'screenshots');
mkdirSync(shotDir, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 800, height: 1000 } });

const errors = [];
// 앱에 넣은 글꼴로 충분하면 구글 글꼴 서버(fonts.gstatic.com)에 요청할 일이 없어야 한다.
const fontFetches = [];
page.on('request', (req) => {
  if (req.url().includes('fonts.gstatic.com')) fontFetches.push(req.url());
});
page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
page.on('console', (m) => {
  if (m.type() === 'error') errors.push(`console: ${m.text()}`);
});

await page.addInitScript(() => {
  window.__tts = [];
  const synth = window.speechSynthesis;
  synth.speak = (u) => {
    window.__tts.push({ text: u.text, lang: u.lang, rate: u.rate });
    setTimeout(() => {
      u.dispatchEvent(new Event('start'));
      u.dispatchEvent(new Event('end'));
    }, 30);
  };
  synth.cancel = () => {};
});

let step = 0;
const shot = async (name) => {
  step += 1;
  const file = join(shotDir, `${String(step).padStart(2, '0')}-${name}.png`);
  await page.waitForTimeout(400);
  await page.screenshot({ path: file });
  console.log(`📸 ${file}`);
};
const tts = () => page.evaluate(() => window.__tts.splice(0));
const button = (name) => page.getByRole('button', { name, exact: false }).first();

await page.goto(url);
// Flutter 접근성 트리 켜기
await page.waitForSelector('flt-semantics-placeholder', { state: 'attached', timeout: 30000 });
await page.evaluate(() => document.querySelector('flt-semantics-placeholder').click());
await page.waitForTimeout(800);

// 1) 첫 화면: 프로필 없음
await button('친구 만들기').waitFor({ timeout: 15000 });
await shot('profile-empty');

// 2) 친구 만들기
await button('친구 만들기').click();
const nameBox = page.getByRole('textbox').first();
await nameBox.waitFor();
// 드문 한글(입력 중 조합 글자)·기호·이모지도 □ 없이 나오는지 확인
await nameBox.fill('줭쀍뷁 ×… 🦖🍓');
await page.waitForTimeout(300);
await shot('rare-glyphs');
await nameBox.fill('테스트');
await page.waitForTimeout(300);
await shot('profile-editor');
await button('저장').click();

// 3) 홈
await button('오늘의 코스').waitFor({ timeout: 10000 });
await shot('home');
await button('테스트, 안녕').click();
await page.waitForTimeout(300);
console.log('🔊 인사:', JSON.stringify(await tts()));

// 4) 부모 잠금
await button('부모님 메뉴').click();
await page.waitForTimeout(500);
await shot('parent-gate');
const question = await page.evaluate(() => {
  const all = [...document.querySelectorAll('flt-semantics, [aria-label]')];
  for (const el of all) {
    const t = (el.getAttribute('aria-label') ?? '') + ' ' + (el.textContent ?? '');
    const m = t.match(/(\d+)\s*×\s*(\d+)/);
    if (m) return [Number(m[1]), Number(m[2])];
  }
  return null;
});
if (!question) throw new Error('곱셈 문제를 찾지 못함');
const answer = String(question[0] * question[1]);
console.log(`🔒 문제 ${question[0]} × ${question[1]} → ${answer}`);
for (const d of answer) await button(d).click();
await button('확인').click();

// 5) 부모 메뉴 → 소리 설정
await button('소리 설정').waitFor({ timeout: 10000 });
await shot('parent-menu');
await button('소리 설정').click();
await page.waitForTimeout(1500); // 음성 점검 결과 대기
await shot('settings');
const listenButtons = page.getByRole('button', { name: '들어보기' });
await listenButtons.nth(0).click();
await page.waitForTimeout(3000);
console.log('🔊 한국어:', JSON.stringify(await tts()));
await listenButtons.nth(1).click();
await page.waitForTimeout(2000);
console.log('🔊 영어:', JSON.stringify(await tts()));

await browser.close();

console.log(fontFetches.length
  ? `⚠️ 외부 글꼴 요청 ${fontFetches.length}건:\n  ` + fontFetches.join('\n  ')
  : '🔤 외부 글꼴 요청 없음 (앱에 넣은 글꼴만 사용)');

if (errors.length) {
  console.log('❌ 브라우저 오류:');
  for (const e of errors) console.log('  ' + e);
  process.exit(1);
}
console.log('✅ 완료 (브라우저 오류 없음)');
