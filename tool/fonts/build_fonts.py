"""앱에 넣을 글꼴을 내려받아 필요한 글자만 잘라 assets/fonts/ 에 만든다.

왜 필요한가:
  Flutter 웹은 한글·이모지 글꼴을 화면에 처음 나올 때 인터넷에서 받아오므로
  그 사이 □(엑박)가 잠깐 보인다. 글꼴을 앱에 넣어두면 시작할 때 미리 로드된다.

결과물 (assets/fonts/):
  Jua-Regular.ttf      기본 글꼴 (둥근 아동용, 한글 약 2,370자 + 영문)
  NotoSansKR-Fill.ttf  Jua에 없는 한글 음절·자모·기호만 담은 보조 글꼴 (굵기 600)
  NotoEmoji.ttf        이모지 (ZWJ 조합 포함, 피부색·국기 제외, 웹 전용으로 사용)
  LICENSE-*.txt        두 글꼴 모두 SIL Open Font License 1.1

사용법:
  python3 -m venv .venv && .venv/bin/pip install fonttools
  .venv/bin/python tool/fonts/build_fonts.py
"""

from __future__ import annotations

import shutil
import urllib.request
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = Path(__file__).resolve().parents[2]
CACHE = Path(__file__).resolve().parent / ".cache"
OUT = ROOT / "assets" / "fonts"

SOURCES = {
    "Jua-Regular.ttf": "https://github.com/google/fonts/raw/main/ofl/jua/Jua-Regular.ttf",
    "OFL-jua.txt": "https://github.com/google/fonts/raw/main/ofl/jua/OFL.txt",
    "NotoSansKR-VF.ttf": "https://github.com/google/fonts/raw/main/ofl/notosanskr/NotoSansKR%5Bwght%5D.ttf",
    "OFL-notosanskr.txt": "https://github.com/google/fonts/raw/main/ofl/notosanskr/OFL.txt",
    "Noto-COLRv1-noflags.ttf": "https://github.com/googlefonts/noto-emoji/raw/main/2D/fonts/Noto-COLRv1-noflags.ttf",
    "LICENSE-noto-emoji.txt": "https://github.com/googlefonts/noto-emoji/raw/main/LICENSE",
}


def fetch(name: str) -> Path:
    path = CACHE / name
    if not path.exists():
        print(f"  다운로드: {name}")
        CACHE.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(SOURCES[name], path)
    return path


def r(start: int, end: int) -> set[int]:
    return set(range(start, end + 1))


def subset_font(font: TTFont, unicodes: list[int], layout: bool) -> TTFont:
    opts = subset.Options()
    opts.layout_features = ["*"] if layout else []
    opts.name_IDs = ["*"]
    opts.notdef_outline = True
    sub = subset.Subsetter(opts)
    sub.populate(unicodes=unicodes)
    sub.subset(font)
    return font


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    # 1) Jua: 그대로 사용
    jua_path = fetch("Jua-Regular.ttf")
    shutil.copy(jua_path, OUT / "Jua-Regular.ttf")
    jua_cmap = TTFont(jua_path).getBestCmap()

    # 2) Noto Sans KR: 굵기 600으로 고정한 뒤 Jua에 없는 글자만
    wanted = (
        r(0xAC00, 0xD7A3)  # 한글 음절 11,172자 (입력 중 조합 글자 포함)
        | r(0x3131, 0x318E)  # 호환 자모 ㄱ~ㅣ
        | r(0x1100, 0x11FF)  # 첫가끝 자모
        | r(0x20, 0x7E)  # ASCII
        | r(0xA0, 0xFF)  # 라틴-1 (× 포함)
        | r(0x2000, 0x206F)  # 문장부호 (… · 등)
        | r(0x2190, 0x22FF)  # 화살표, 수학 기호
        | r(0x25A0, 0x25FF)  # 도형
        | r(0x3000, 0x303F)  # CJK 문장부호
    )
    need = sorted(c for c in wanted if c not in jua_cmap)
    vf = TTFont(fetch("NotoSansKR-VF.ttf"))
    fill = instancer.instantiateVariableFont(vf, {"wght": 600})
    subset_font(fill, need, layout=True).save(OUT / "NotoSansKR-Fill.ttf")

    # 3) 이모지: 단일 이모지 + ZWJ 조합(👨‍👧 등). 피부색 변형만 제외 (+500KB 절약)
    emoji = TTFont(fetch("Noto-COLRv1-noflags.ttf"))
    skin_tones = r(0x1F3FB, 0x1F3FF)
    singles = [c for c in emoji.getBestCmap() if c > 0x2000 and c not in skin_tones]
    subset_font(emoji, singles + [0xFE0F, 0x200D, 0x20E3], layout=True).save(
        OUT / "NotoEmoji.ttf"
    )

    # 4) 라이선스
    licenses = {
        "OFL-jua.txt": "LICENSE-Jua.txt",
        "OFL-notosanskr.txt": "LICENSE-NotoSansKR.txt",
        "LICENSE-noto-emoji.txt": "LICENSE-NotoEmoji.txt",
    }
    for src, dst in licenses.items():
        shutil.copy(fetch(src), OUT / dst)

    for f in sorted(OUT.iterdir()):
        print(f"  {f.name:28s} {f.stat().st_size // 1024:6d} KB")


if __name__ == "__main__":
    main()
