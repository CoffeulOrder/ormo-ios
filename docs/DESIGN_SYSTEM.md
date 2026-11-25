# ORMO Design System

ORSO의 대학 내 카페 모바일 오더 서비스 **ORMO**의 디자인 시스템을 Figma 원본에서 Markdown으로 옮긴 문서다.

- **원본**: [Figma · Design System](https://www.figma.com/design/EM9tNGNPK7FxUAvzS9909M/Design-System?node-id=0-1)
- **서체**: Pretendard
- **기반**: TDS(앱인토스) 구조 — Base 팔레트 + Semantic 토큰 2단 컬러, Light / Dark 모드. Blue 팔레트만 ORSO Blue(`#298DFF`) 계열.
- **플랫폼**: Mobile(터치, 기준 폭 375) · Web(마우스) · iPad(Owner App 전용). 컴포넌트 문서마다 지원 플랫폼과 버전을 적었다.
- **표기**: `백틱` = 토큰/변수 이름, `Text/Primary` 같은 슬래시 이름 = Semantic 컬러 토큰, `Body md/Semibold` = 텍스트 스타일 (크기/굵기).
- **컴포넌트**: 34종 (기본 27 + 모바일 전용 Store Card·Menu Card 2 + Owner App(iPad) 5)
- **Figma 변수 컬렉션**: Color 189개(Base 147 · Semantic 42, Light/Dark) · Tokens 73개 · Typography 27개.

## 목차

1. [Foundation](#1-foundation) — Colors · Typography · Spacing/Radius/Size · Effects · Icons
2. [Actions](#2-actions) — Action Button · Bottom CTA · Top Navigation
3. [Inputs](#3-inputs) — Checkbox · Radio · Switch · Chip · Segmented Control · Field · Text Input & Textarea · Quantity Picker
4. [Data Display](#4-data-display) — Badge · Count Badge · Image Frame · List · Divider · Store Card · Menu Card
5. [Feedback](#5-feedback) — Callout · Snackbar · Result · Skeleton · Content Placeholder · Progress Circle · Scroll Fog · Alert Dialog
6. [Overlays](#6-overlays) — Bottom Sheet · Menu
7. [Navigation](#7-navigation) — Tabs
8. [Owner App · iPad](#8-owner-app--ipad) — Top Bar · Column Head · Order Card · PIN Pad · Table
9. [부록: 원본 문서의 불일치](#9-부록-원본-문서의-불일치)

---

## 1. Foundation

### 1.1 Colors

TDS(앱인토스) 컬러 시스템과 같은 구조다. **Base 팔레트** 위에 **역할 이름이 붙은 Semantic 토큰**을 올린 2단 구조이며, 모든 토큰은 Light / Dark 값을 가진다. Blue 팔레트만 ORMO 브랜드 가이드라인의 ORSO Blue(`#298DFF`) 계열이다.

**Figma Variables `Color` 컬렉션**: 189개 (Base 147 + Semantic 42), 모드 Light / Dark.

#### 1.1.1 사용 원칙

- 컴포넌트에는 **Semantic 토큰을 먼저** 쓴다. 배지·강조처럼 Semantic에 없는 색만 Base 팔레트를 바로 쓴다.
- 눌림 상태는 기본 색 위에 `Fill/Pressed`를 한 겹 덮는다. "… Pressed" 색은 따로 만들지 않는다.
- 비활성 배경은 `Fill/Neutral Weak`, 비활성·안내 글자는 `Text/Quaternary`, 비활성 아이콘은 `Icon/Quaternary`.
- TDS와 다른 곳은 두 군데: ① Blue 팔레트(ORSO Blue 계열) ② `Text/Brand`의 Light 값(Blue 700, 흰 배경 대비 5.0:1).
- Brand 팔레트 9색은 로고·브랜드 그래픽용이다. 화면 UI에는 Blue 팔레트와 Semantic 토큰을 쓴다.
- 그림자 색 토큰은 효과 스타일에 연결돼 있다: Shadow/Small → `Shadow/Tiny`, Shadow/Medium → `Shadow/Weak`, Shadow/Large → `Shadow/Medium`.

#### 1.1.2 Brand 팔레트 (브랜드 가이드라인, 9색)

| 이름 | Hex |
|---|---|
| ORSO Blue | `#298DFF` |
| Black | `#000000` |
| Navy | `#001129` |
| Deep | `#1759C4` |
| Azure | `#5CA9FF` |
| Sky | `#8FCBFF` |
| Light | `#DDF2FF` |
| Grey | `#E0E2E6` |
| White | `#FFFFFF` |

**텍스트 대비 (Light / Dark)** — 흰 바탕(Light)·`#17171C` 바탕(Dark) 기준, On Fill 계열은 그 채움 위에서 잰 값.

| Token | 참조 (Light · Dark) | 대비 |
|---|---|---|
| Text/Strong | Grey 900 · Grey 900 | 16.6 / 17.9 |
| Text/Primary | Grey Opacity 800 · Grey 800 | 11.0 / 14.1 |
| Text/Secondary | Grey Opacity 700 · Grey Opacity 700 | 7.1 / 10.2 |
| Text/Tertiary | Grey Opacity 600 · Grey Opacity 600 | 4.6 / 6.7 |
| Text/Quaternary | Grey Opacity 500 · Grey Opacity 500 | 3.0 / 4.4 |
| Text/Brand | Blue 700 · Blue 600 | 5.0 / 6.3 |
| Text/Danger | Red 600 · Red 600 | 4.5 / 5.9 |
| Text/Success | Green 700 · Green 700 | 3.9 / 11.0 |
| Text/Warning | Yellow 900 · Yellow 700 | 3.0 / 13.0 |
| Text/On Fill | `#FFFFFF` · `#FFFFFF` | 7.1 / 6.0 |
| Text/On Fill Brand | `#FFFFFF` · `#FFFFFF` | 3.3 / 3.3 |
| Text/On Fill Warning | Grey Opacity 800 · `#000C1E` 80% | 8.2 / 7.5 |

> On Fill 두 줄은 Figma 문서에서 토큰 이름 라벨 없이 값만 읽혔다. 순서와 수치(흰 글자가 Fill/Neutral 위 7.1·6.0, Fill/Brand 위 3.3)로 위와 같이 매핑했다.

#### 1.1.3 Base Palette

Figma Variables → `Color` 컬렉션 (모드: Light / Dark). `Base/*` 147개. 값은 `Light / Dark`이며 한쪽만 있으면 두 모드가 같다. 투명도 값은 `#RRGGBB @알파%`.

**Grey** (Light / Dark)

| Step | Light | Dark |
|---|---|---|
| Grey 50 | `#F9FAFB` | `#202027` |
| Grey 100 | `#F2F4F6` | `#2C2C35` |
| Grey 200 | `#E5E8EB` | `#3C3C47` |
| Grey 300 | `#D1D6DB` | `#4D4D59` |
| Grey 400 | `#B0B8C1` | `#62626D` |
| Grey 500 | `#8B95A1` | `#7E7E87` |
| Grey 600 | `#6B7684` | `#9E9EA4` |
| Grey 700 | `#4E5968` | `#C3C3C6` |
| Grey 800 | `#333D4B` | `#E4E4E5` |
| Grey 900 | `#191F28` | `#FFFFFF` |

**Grey Opacity**

| Step | Light | Dark |
|---|---|---|
| Grey Opacity 50 | `#001733` @2% | `#D1D1FD` @5% |
| Grey Opacity 100 | `#022047` @5% | `#D9D9FF` @11% |
| Grey Opacity 200 | `#001B37` @10% | `#DEDEFF` @19% |
| Grey Opacity 300 | `#001D3A` @18% | `#E0E0FF` @27% |
| Grey Opacity 400 | `#001936` @31% | `#E8E8FD` @36% |
| Grey Opacity 500 | `#031832` @46% | `#F2F2FF` @47% |
| Grey Opacity 600 | `#00132B` @58% | `#F8F8FF` @60% |
| Grey Opacity 700 | `#031228` @70% | `#FDFDFF` @75% |
| Grey Opacity 800 | `#000C1E` @80% | `#FDFDFE` @89% |
| Grey Opacity 900 | `#020913` @91% | `#FFFFFF` |

**Blue** (ORSO Blue 계열 — 이 팔레트만 TDS와 다르다)

| Step | Light | Dark |
|---|---|---|
| Blue 50 | `#EBF5FF` | `#1E2D4D` |
| Blue 100 | `#C9E4FF` | `#1F396A` |
| Blue 200 | `#91C6FF` | `#1E488C` |
| Blue 300 | `#67AFFE` | `#1A5CB3` |
| Blue 400 | `#459CFF` | `#1672D9` |
| Blue 500 | `#298DFF` | `#298DFF` |
| Blue 600 | `#0F7BF2` | `#379DFE` |
| Blue 700 | `#006BDF` | `#59B2FE` |
| Blue 800 | `#025CC5` | `#8BCEFE` |
| Blue 900 | `#084DA7` | `#C7E8FE` |

**Blue Opacity** (모두 `#298DFF` 기반, Dark는 별도 값)

| Step | Light | Dark |
|---|---|---|
| Blue Opacity 50 | `#298DFF` @5% | `#3C88EB` @11% |
| Blue Opacity 100 | `#298DFF` @9% | `#397CDF` @20% |
| Blue Opacity 200 | `#298DFF` @14% | `#3B7CD5` @28% |
| Blue Opacity 300 | `#298DFF` @27% | `#317BDC` @41% |
| Blue Opacity 400 | `#298DFF` @47% | `#2876DD` @61% |
| Blue Opacity 500 | `#298DFF` @80% | `#1274E8` @81% |

**Red**

| Step | Light | Dark |
|---|---|---|
| Red 50 | `#FFEEEE` | `#3C2020` |
| Red 100 | `#FFD4D6` | `#562025` |
| Red 200 | `#FEAFB4` | `#7A242D` |
| Red 300 | `#FB8890` | `#9E2733` |
| Red 400 | `#F66570` | `#CA2F3D` |
| Red 500 | `#F04452` | `#F04251` |
| Red 600 | `#E42939` | `#FA616D` |
| Red 700 | `#D22030` | `#FE818B` |
| Red 800 | `#BC1B2A` | `#FFA8AD` |
| Red 900 | `#A51926` | `#FFD1D3` |

**Red Opacity**

| Step | Light | Dark |
|---|---|---|
| Red Opacity 50 | `#EF222F` @5% | `#D3665C` @11% |
| Red Opacity 100 | `#ED2831` @8% | `#DB5157` @20% |
| Red Opacity 200 | `#ED2831` @13% | `#D9454F` @30% |
| Red Opacity 300 | `#ED2831` @24% | `#DF3A44` @45% |
| Red Opacity 400 | `#ED2831` @43% | `#E32A3B` @64% |
| Red Opacity 500 | `#EF222F` @69% | `#E32A3B` @81% |

**Orange**

| Step | Light | Dark |
|---|---|---|
| Orange 50 | `#FFF3E0` | `#3D2500` |
| Orange 100 | `#FFE0B0` | `#563200` |
| Orange 200 | `#FFCD80` | `#804600` |
| Orange 300 | `#FFBD51` | `#A85F00` |
| Orange 400 | `#FFA927` | `#CF7200` |
| Orange 500 | `#FE9800` | `#F18600` |
| Orange 600 | `#FB8800` | `#FD9528` |
| Orange 700 | `#F57800` | `#FFA861` |
| Orange 800 | `#ED6700` | `#FFC39E` |
| Orange 900 | `#E45600` | `#FFE4D6` |

**Yellow**

| Step | Light | Dark |
|---|---|---|
| Yellow 50 | `#FFF9E7` | `#3D2D1A` |
| Yellow 100 | `#FFEFBF` | `#724C1E` |
| Yellow 200 | `#FFE69B` | `#B56F1D` |
| Yellow 300 | `#FFDD78` | `#EB8B1E` |
| Yellow 400 | `#FFD158` | `#FFA126` |
| Yellow 500 | `#FFC342` | `#FFB134` |
| Yellow 600 | `#FFB331` | `#FFC259` |
| Yellow 700 | `#FAA131` | `#FFD68A` |
| Yellow 800 | `#EE8F11` | `#FFE5B2` |
| Yellow 900 | `#DD7D02` | `#FFF1D4` |

**Yellow Opacity**

| Step | Light | Dark |
|---|---|---|
| Yellow Opacity 50 | `#F8C600` @10% | `#C8AB4C` @8% |
| Yellow Opacity 100 | `#FBB600` @17% | `#E6A856` @13% |
| Yellow Opacity 200 | `#FCB600` @34% | `#E39E35` @19% |
| Yellow Opacity 300 | `#F9AC00` @59% | `#DA8F25` @31% |
| Yellow Opacity 400 | `#FFA000` @85% | `#F88A2A` @41% |
| Yellow Opacity 500 | `#FA8200` @91% | `#F98527` @56% |

**Green**

| Step | Light | Dark |
|---|---|---|
| Green 50 | `#F0FAF6` | `#153729` |
| Green 100 | `#AEEFD5` | `#135338` |
| Green 200 | `#76E4B8` | `#136D47` |
| Green 300 | `#3FD599` | `#138A59` |
| Green 400 | `#15C47E` | `#13A065` |
| Green 500 | `#03B26C` | `#16BB76` |
| Green 600 | `#02A262` | `#26CF88` |
| Green 700 | `#029359` | `#4EE4A6` |
| Green 800 | `#028450` | `#82F6C5` |
| Green 900 | `#027648` | `#CCFFEA` |

**Green Opacity**

| Step | Light | Dark |
|---|---|---|
| Green Opacity 50 | `#00B75C` @5% | `#528E5C` @11% |
| Green Opacity 100 | `#00B75C` @10% | `#3D7B65` @23% |
| Green Opacity 200 | `#00B75C` @18% | `#37846C` @30% |
| Green Opacity 300 | `#00B75C` @35% | `#2B856E` @44% |
| Green Opacity 400 | `#12B26C` @59% | `#1C866C` @61% |
| Green Opacity 500 | `#009F6A` @88% | `#1B8765` @80% |

**Teal**

| Step | Light | Dark |
|---|---|---|
| Teal 50 | `#EDF8F8` | `#203537` |
| Teal 100 | `#BCE9E9` | `#224E51` |
| Teal 200 | `#89D8D8` | `#226368` |
| Teal 300 | `#58C7C7` | `#247E85` |
| Teal 400 | `#30B6B6` | `#26939A` |
| Teal 500 | `#18A5A5` | `#2EAAB2` |
| Teal 600 | `#109595` | `#43BEC7` |
| Teal 700 | `#0C8585` | `#65D4DC` |
| Teal 800 | `#097575` | `#9BE8EE` |
| Teal 900 | `#076565` | `#D6FCFF` |

**Teal Opacity**

| Step | Light | Dark |
|---|---|---|
| Teal Opacity 50 | `#22AAAA` @6% | `#4A8281` @12% |
| Teal Opacity 100 | `#22AAAA` @11% | `#427A7F` @22% |
| Teal Opacity 200 | `#22AAAA` @19% | `#348181` @30% |
| Teal Opacity 300 | `#22AAAA` @33% | `#298282` @43% |
| Teal Opacity 400 | `#22AAAA` @60% | `#178282` @63% |
| Teal Opacity 500 | `#009696` @85% | `#168888` @78% |

**Purple**

| Step | Light | Dark |
|---|---|---|
| Purple 50 | `#F9F0FC` | `#3F2447` |
| Purple 100 | `#EDCCF8` | `#522361` |
| Purple 200 | `#DA9BEF` | `#66247B` |
| Purple 300 | `#C770E4` | `#7B2595` |
| Purple 400 | `#B44BD7` | `#962FB5` |
| Purple 500 | `#A234C7` | `#AE3DD1` |
| Purple 600 | `#9128B4` | `#C353E5` |
| Purple 700 | `#8222A2` | `#D77CF2` |
| Purple 800 | `#73228E` | `#EAACFC` |
| Purple 900 | `#65237B` | `#F6D9FF` |

**Purple Opacity**

| Step | Light | Dark |
|---|---|---|
| Purple Opacity 50 | `#9754E2` @5% | `#8B5EB5` @13% |
| Purple Opacity 100 | `#9754E2` @8% | `#9362C0` @21% |
| Purple Opacity 200 | `#9754E2` @16% | `#905FC9` @30% |
| Purple Opacity 300 | `#8D59E9` @28% | `#9255E2` @44% |
| Purple Opacity 400 | `#9555E3` @49% | `#994EE5` @63% |
| Purple Opacity 500 | `#9555E3` @76% | `#9A52E0` @81% |

**Static** (모드와 무관)

| Token | 값 |
|---|---|
| Static White | `#FFFFFF` |
| Static Black | `#000000` |

**Static White Opacity** (두 모드 동일 값)

| Step | 값 |
|---|---|
| Static White Opacity 50 | `#D1D1FD` @5% |
| Static White Opacity 100 | `#D9D9FF` @11% |
| Static White Opacity 200 | `#DEDEFF` @19% |
| Static White Opacity 300 | `#E0E0FF` @27% |
| Static White Opacity 400 | `#E8E8FD` @36% |
| Static White Opacity 500 | `#F2F2FF` @47% |
| Static White Opacity 600 | `#F8F8FF` @60% |
| Static White Opacity 700 | `#FDFDFF` @75% |
| Static White Opacity 800 | `#FDFDFE` @89% |
| Static White Opacity 900 | `#FFFFFF` |

#### 1.1.4 Semantic Tokens (42)

`Semantic/*` — 역할 이름으로 쓰는 토큰. 컴포넌트는 Base가 아니라 이 토큰을 참조한다. 괄호는 참조하는 Base 토큰.

**Background**

| Token | Light | Dark | 용도 |
|---|---|---|---|
| Background/Default | `#FFFFFF` | `#17171C` | 페이지 기본 배경 |
| Background/Lower | Grey 100 (`#F2F4F6`) | `#101013` | 회색 바닥 배경 (카드가 올라가는 면) |
| Background/Floated | `#FFFFFF` | `#202027` | 바텀시트·다이얼로그·메뉴 등 떠 있는 면 |
| Background/Upper | Grey Opacity 50 (`#001733` @2%) | Grey Opacity 50 (`#D1D1FD` @5%) | 면 위에 한 단계 올린 옅은 영역 |
| Background/Dim | `#000000` @20% | `#000000` @56% | 오버레이 딤 |

**Text**

| Token | Light | Dark | 용도 |
|---|---|---|---|
| Text/Strong | Grey 900 (`#191F28`) | Grey 900 (`#FFFFFF`) | 가장 강한 제목 |
| Text/Primary | Grey Opacity 800 (`#000C1E` @80%) | Grey 800 (`#E4E4E5`) | 본문 기본 |
| Text/Secondary | Grey Opacity 700 (`#031228` @70%) | Grey Opacity 700 (`#FDFDFF` @75%) | 보조 설명 |
| Text/Tertiary | Grey Opacity 600 (`#00132B` @58%) | Grey Opacity 600 (`#F8F8FF` @60%) | 캡션·메타 정보 |
| Text/Quaternary | Grey Opacity 500 (`#031832` @46%) | Grey Opacity 500 (`#F2F2FF` @47%) | 비활성 텍스트 |
| Text/Brand | Blue 700 (`#006BDF`) | Blue 600 (`#379DFE`) | 브랜드 강조·링크 (Light는 Blue 700: 흰 배경 대비 5.0:1) |
| Text/Danger | Red 600 (`#E42939`) | Red 600 (`#FA616D`) | 오류 |
| Text/Success | Green 700 (`#029359`) | Green 700 (`#4EE4A6`) | 성공 |
| Text/Warning | Yellow 900 (`#DD7D02`) | Yellow 700 (`#FFD68A`) | 주의 |
| Text/On Fill | `#FFFFFF` | `#FFFFFF` | 진한 채움 위 텍스트 |
| Text/On Fill Warning | Grey Opacity 800 (`#000C1E` @80%) | `#000C1E` @80% | 흰 채움(Inverse) 위 텍스트 |
| Text/On Fill Brand | `#FFFFFF` | `#FFFFFF` | (설명 없음) |

**Icon**

| Token | Light | Dark | 용도 |
|---|---|---|---|
| Icon/Primary | Grey Opacity 600 (`#00132B` @58%) | Grey Opacity 600 (`#F8F8FF` @60%) | 기본 아이콘 |
| Icon/Secondary | Grey Opacity 500 (`#031832` @46%) | Grey Opacity 500 (`#F2F2FF` @47%) | 보조 아이콘 |
| Icon/Tertiary | Grey Opacity 400 (`#001936` @31%) | Grey Opacity 400 (`#E8E8FD` @36%) | 약한 아이콘 |
| Icon/Quaternary | Grey Opacity 300 (`#001D3A` @18%) | Grey Opacity 300 (`#E0E0FF` @27%) | 비활성 아이콘 |
| Icon/Brand | Blue 500 (`#298DFF`) | Blue 600 (`#379DFE`) | 브랜드 아이콘 |
| Icon/Danger | Red 600 (`#E42939`) | Red 600 (`#FA616D`) | 오류 아이콘 |
| Icon/Success | Green 600 (`#02A262`) | Green 600 (`#26CF88`) | 성공 아이콘 |
| Icon/Warning | Yellow 800 (`#EE8F11`) | Yellow 700 (`#FFD68A`) | 주의 아이콘 |

**Fill**

| Token | Light | Dark | 용도 |
|---|---|---|---|
| Fill/Brand | Blue 500 (`#298DFF`) | Blue 500 (`#298DFF`) | Primary 채움 |
| Fill/Brand Weak | `#298DFF` @16% | `#298DFF` @16% | Primary 약한 채움 |
| Fill/Neutral | Grey 700 (`#4E5968`) | Grey 400 (`#62626D`) | 중립 진한 채움 |
| Fill/Neutral Weak | `#07194C` @5% | `#D9D9FF` @11% | 중립 약한 채움 (보조 버튼·입력 배경) |
| Fill/Danger | Red 500 (`#F04452`) | Red 500 (`#F04251`) | 위험 채움 |
| Fill/Danger Weak | `#F04452` @16% | `#F04452` @16% | 위험 약한 채움 |
| Fill/Success | Green 500 (`#03B26C`) | Green 500 (`#16BB76`) | 성공 채움 |
| Fill/Success Weak | `#02A262` @16% | `#02A262` @16% | 성공 약한 채움 |
| Fill/Warning | Yellow 500 (`#FFC342`) | Yellow 500 (`#FFB134`) | 주의 채움 |
| Fill/Warning Weak | `#FFB331` @16% | `#FFB331` @16% | 주의 약한 채움 |
| Fill/Inverse | Static White (`#FFFFFF`) | Static White (`#FFFFFF`) | 어두운 면 위 흰 채움 |
| Fill/Inverse Weak | Static White Opacity 200 (`#DEDEFF` @19%) | 같음 | 토스트 안 액션 버튼 배경 |
| Fill/Pressed | Grey Opacity 100 (`#022047` @5%) | Grey Opacity 100 (`#D9D9FF` @11%) | 리스트·투명 버튼 눌림 오버레이 |

**Border / Shadow**

| Token | Light | Dark | 용도 |
|---|---|---|---|
| Border/Default | Grey Opacity 200 (`#001B37` @10%) | Background/Lower (`#101013`) | 기본 선·구분선 |
| Shadow/Tiny | Grey Opacity 200 (`#001B37` @10%) | `#000000` @50% | (설명 없음) |
| Shadow/Weak | Grey Opacity 200 (`#001B37` @10%) | `#000000` @50% | (설명 없음) |
| Shadow/Medium | Grey Opacity 300 (`#001D3A` @18%) | `#000000` @50% | (설명 없음) |

### 1.2 Typography

크기(Display 2xl ~ Body xs)와 굵기(Regular · Medium · Semibold · Bold)만 고르면 되는 단순한 구조. 모든 스타일의 서체·굵기·크기·**행간**이 **Typography 변수**에 연결돼 있어 `Font Family/Base` 값 하나만 바꾸면 전체 서체가 바뀐다. 서체는 **Pretendard**.

#### 1.2.1 스케일과 행간

크기마다 행간(line height)이 **px 고정값 한 쌍**으로 정해져 있다 (`Font Size/*` ↔ `Line Height/*`).

| Style | Font size | Line height | 행간 비율 | 행간 − 크기 | 용도 |
|---|---|---|---|---|---|
| Display / 2xl | 72 | 90 | 1.25 | +18 | 랜딩 히어로 |
| Display / xl | 60 | 72 | 1.20 | +12 | 랜딩 히어로 |
| Display / lg | 48 | 60 | 1.25 | +12 | 큰 숫자 · 마케팅 |
| Display / md | 36 | 44 | 1.22 | +8 | 웹 페이지 제목 |
| Display / sm | 30 | 38 | 1.27 | +8 | 모바일 큰 제목 · 금액 |
| Display / xs | 24 | 32 | 1.33 | +8 | 모바일 화면 제목 |
| Body / xl | 20 | 30 | 1.50 | +10 | 섹션 제목 · 바텀시트 제목 |
| Body / lg | 18 | 28 | 1.56 | +10 | 카드 제목 · XL 버튼 |
| Body / md | 16 | 24 | 1.50 | +8 | 본문 · 리스트 제목 · 입력값 |
| Body / sm | 14 | 20 | 1.43 | +6 | 보조 본문 · 라벨 · S 버튼 |
| Body / xs | 12 | 18 | 1.50 | +6 | 캡션 · 배지 · 메타 정보 |

> 행간 비율 · 행간 − 크기 열은 Figma 값(size, line height)에서 계산한 파생값이다 (비율은 소수 셋째 자리에서 반올림).

**행간 규칙 (Figma 텍스트 스타일 44개를 확인한 결과)**
- 행간은 **px 고정값**이다 (Auto / 퍼센트 아님). 스타일 설명에도 `72px / 90px · Regular` 형식으로 적혀 있다.
- 행간은 **굵기와 무관**하다. Regular · Medium · Semibold · Bold 4가지가 같은 크기에서 같은 행간을 쓴다 (예: Body md 네 굵기 모두 16 / 24).
- **자간(letter spacing)은 전 스타일 0%**.
- 크기 단계는 두 구간으로 나뉜다.
  - **Display (24 이상)**: 비율 1.20 ~ 1.33으로 촘촘하다 (제목·숫자용).
  - **Body (20 이하)**: 비율 1.43 ~ 1.56으로 여유 있다 (여러 줄로 읽는 글용).
- 행간은 모두 짝수 px이다. 크기 대비 추가분은 Body 구간 +6 ~ +10, Display 구간 +8 ~ +18.
- 한 줄짜리 텍스트의 높이는 곧 행간이다. 컴포넌트 높이는 "행간 + 위아래 여백"으로 맞춘다 (아래 1.2.3).

#### 1.2.2 텍스트 스타일 이름과 굵기

각 스타일은 Regular / Medium / Semibold / Bold 4가지 굵기로, 이름은 `크기/굵기` 형식이다 (예: `Body md/Semibold`). 총 11 × 4 = **44개 텍스트 스타일**. 모든 스타일의 letter spacing은 0%.

| Style | Regular | Medium | Semibold | Bold |
|---|---|---|---|---|
| Display 2xl | 72 / 90 | 72 / 90 | 72 / 90 | 72 / 90 |
| Display xl | 60 / 72 | 60 / 72 | 60 / 72 | 60 / 72 |
| Display lg | 48 / 60 | 48 / 60 | 48 / 60 | 48 / 60 |
| Display md | 36 / 44 | 36 / 44 | 36 / 44 | 36 / 44 |
| Display sm | 30 / 38 | 30 / 38 | 30 / 38 | 30 / 38 |
| Display xs | 24 / 32 | 24 / 32 | 24 / 32 | 24 / 32 |
| Body xl | 20 / 30 | 20 / 30 | 20 / 30 | 20 / 30 |
| Body lg | 18 / 28 | 18 / 28 | 18 / 28 | 18 / 28 |
| Body md | 16 / 24 | 16 / 24 | 16 / 24 | 16 / 24 |
| Body sm | 14 / 20 | 14 / 20 | 14 / 20 | 14 / 20 |
| Body xs | 12 / 18 | 12 / 18 | 12 / 18 | 12 / 18 |

(표 값은 `font size / line height`, px)

> 가이드: 본문은 Body md(16/24)를 기본으로, 보조 설명은 Body sm(14/20)으로 한 단계 낮춘다. 숫자와 금액은 Semibold 이상으로 강조한다.

#### 1.2.3 컴포넌트에서의 행간

각 컴포넌트 스펙에 적힌 텍스트 스타일을 행간 기준으로 묶은 것. 한 줄 텍스트의 높이가 이 값이다.

| Line height | Style | 쓰는 곳 (컴포넌트 스펙 기준) |
|---|---|---|
| 18 | Body xs | Badge M · Count Badge S, Segmented S 라벨 |
| 20 | Body sm | Badge L · Count Badge M, Chip, Action Button S, Callout, Field 라벨·도움말·오류, Segmented M 라벨, Text Input M, List 설명, Snackbar 액션 |
| 24 | Body md | Action Button M · L, List 제목, Text Input L · Textarea, Snackbar 메시지, Menu 라벨, Alert Dialog 설명, Result 설명, Quantity Picker 수량, Top Navigation 텍스트 액션 |
| 28 | Body lg | Action Button XL, Top Navigation 제목, Tabs L, Result 제목, List Header Large |
| 30 | Body xl | Alert Dialog 제목, Bottom Sheet 제목 |
| 32 | Display xs | Top Navigation 큰 제목(Large) |

**버튼 높이와 행간 (산출)** — 컨테이너 높이 − 행간 = 위아래 합계 여백:

| Size | 높이 | 텍스트 스타일 | 행간 | 위아래 여백 합 |
|---|---|---|---|---|
| S | 32 | Body sm/Semibold | 20 | 12 (각 6) |
| M | 40 | Body md/Semibold | 24 | 16 (각 8) |
| L | 48 | Body md/Semibold | 24 | 24 (각 12) |
| XL | 56 | Body lg/Semibold | 28 | 28 (각 14) |

**Typography 변수 (27개)**: `Font Family/Base` = Pretendard · `Font Weight/{Regular, Medium, Semibold, Bold}` · `Font Size/*` (11단계) · `Line Height/*` (11단계, 1.2.1 표의 값)

**iOS 구현**: `ORMO/DesignSystem/Typography.swift`의 `TypographyStyle`이 크기·굵기·행간을 한 번에 들고 있고, `View.typography(_:)`가 `.font()` + `.lineSpacing()` + 위아래 패딩으로 위 표의 고정 행간을 그대로 반영한다(이 패딩이 없으면 시스템 폰트의 기본 줄 간격이 Figma 값보다 좁아 행간·텍스트 사이 여백이 부족해 보인다). 화면 코드에서는 `.font(Typography.X)` 대신 `.typography(Typography.X)`를 쓴다.

### 1.3 Spacing, Radius & Size

모든 여백·라운드·높이·아이콘 크기는 **Tokens 변수에서만** 가져온다. 스케일에 없는 값(6, 10, 14, 18px 등)은 쓰지 않고, 꼭 필요하면 새 토큰으로 제안한다. 전체 변수 값은 1.3.4 참고.

#### 1.3.1 쓰임

**Spacing** — padding · gap · margin: `spacing-0/2/4/8/12/16/20/24/32/40/48/64`

**Radius**

| Token | px | 쓰는 곳 |
|---|---|---|
| `radius-none` | 0 | 구분선 · 풀블리드 |
| `radius-xs` | 4 | 체크박스 · 태그 |
| `radius-sm` | 8 | S 버튼 · 목록 안쪽 칸 |
| `radius-10` | 10 | 높이 38 컨트롤 · Segmented 안쪽 칸 |
| `radius-md` | 12 | 높이 40 컨트롤 · 썸네일 |
| `radius-14` | 14 | 높이 48 컨트롤 · 입력창 · L 버튼 |
| `radius-lg` | 16 | 카드 · 높이 56 컨트롤 |
| `radius-xl` | 20 | 바텀시트 |
| `radius-2xl` | 24 | 다이얼로그 · 큰 카드 |
| `radius-full` | 999 | 칩 · 아바타 · 스위치 |

**Height** — 컴포넌트 높이

| Token | px | 쓰는 곳 |
|---|---|---|
| `height-2xs` | 24 | Badge · 작은 Chip |
| `height-xs` | 32 | S 버튼 · Chip |
| `height-sm` | 36 | 작은 입력 |
| `height-md` | 40 | M 버튼 · M 입력 |
| `height-lg` | 48 | L 버튼 · L 입력 |
| `height-xl` | 56 | XL 버튼 · 하단 CTA |
| `height-textarea` | 120 | Textarea 최소 |

**Icon size**: `icon-xs` 12 · `icon-sm` 16 · `icon-md` 20 · `icon-lg` 24 · `icon-xl` 32

**Layout (모바일)**
- `screen-mobile` 375px — 모바일 기준 폭
- `page-margin` — 화면 좌우 여백 (**문서상 `spacing-20`**, 변수 값은 `spacing-24` — 아래 "불일치" 참고)
- `section-gap` `spacing-32` — 섹션 사이 간격
- `border-thin` 1px · `border-thick` 2px — 기본 선 · 포커스/오류 선

#### 1.3.2 Control radius (높이별 모서리)

| 높이 | 모서리 | 토큰 | 쓰는 곳 |
|---|---|---|---|
| 32 | 8 | `control-radius-32` → `radius-sm` | S 버튼 |
| 38 | 10 | `segmented-radius-s` → `radius-10` | Segmented S |
| 40 | 12 | `control-radius-40` → `radius-md` | M 버튼 · Quantity S · Pagination |
| 48 | 14 | `control-radius-48` → `radius-14` | L 버튼 · 입력창 M · Segmented M · 피커 선택 띠 · Side Nav |
| 56 | 16 | `control-radius-56` → `radius-lg` | XL 버튼 · 입력창 L |

- 모서리 ≈ 높이 × 0.28을 짝수로 반올림 (32→8, 38→10, 40→12, 48→14, 56→16). 크기가 달라도 둥글기가 같아 보인다.
- 안쪽 칸 모서리 = 바깥 모서리 − 안쪽 여백. Segmented M 14 − 4 = 10, Listbox·Menu 16 − 8 = 8.
- 높이가 정해지지 않은 컨테이너는 `radius-lg` 16(카드·Callout) / `radius-xl` 20(시트) / `radius-2xl` 24(다이얼로그), 알약형은 `radius-full`.

#### 1.3.3 Platform size (플랫폼별 크기)

| 플랫폼 | 입력창 · Select | 주요 버튼 | 보조 버튼 | 줄 단위 영역 | 칩 · Segmented |
|---|---|---|---|---|---|
| Mobile (터치) | L 56 | XL 56 · L 48 | M 40 | `row-height` 48 | Chip L 40 · Segmented M 48 |
| Web (마우스) | M 48 | L 48 · M 40 | S 32 | `row-height` 48 | Chip M 36 · Segmented S 38 |

- 기본 규칙: 모바일은 큰 크기, 웹(마우스)은 한 단계 작은 크기. 각 컴포넌트 문서의 Size guide에 크기별 쓰임이 있다.
- 손가락으로 누르는 줄(목록·메뉴·피커·달력)은 플랫폼과 무관하게 최소 48.
- 한 화면 안에서는 같은 역할의 크기를 섞지 않는다.

#### 1.3.4 Tokens 컬렉션 전체 값 (변수 73개, 모드: Default)

**Spacing**

| Token | px |
|---|---|
| `spacing-0` | 0 |
| `spacing-2` | 2 |
| `spacing-4` | 4 |
| `spacing-8` | 8 |
| `spacing-12` | 12 |
| `spacing-16` | 16 |
| `spacing-20` | 20 |
| `spacing-24` | 24 |
| `spacing-32` | 32 |
| `spacing-40` | 40 |
| `spacing-48` | 48 |
| `spacing-64` | 64 |

**Radius**

| Token | px | 비고 |
|---|---|---|
| `radius-none` | 0 | |
| `radius-xs` | 4 | |
| `radius-sm` | 8 | |
| `radius-10` | 10 | 높이 38 컨트롤 · 48 컨트롤의 안쪽 칸 |
| `radius-md` | 12 | |
| `radius-14` | 14 | 높이 48 컨트롤 (높이의 약 28%) |
| `radius-lg` | 16 | |
| `radius-xl` | 20 | |
| `radius-2xl` | 24 | |
| `radius-full` | 999 | |

**Height**

| Token | px | 용도 |
|---|---|---|
| `height-2xs` | 24 | Badge·작은 Chip |
| `height-xs` | 32 | Small 버튼·Chip |
| `height-sm` | 36 | 작은 입력 |
| `height-md` | 40 | Medium 버튼 |
| `height-lg` | 48 | Large 버튼·입력 필드 |
| `height-xl` | 56 | XLarge 버튼·하단 CTA |
| `height-textarea` | 120 | Textarea 최소 높이 (3줄 + 상하 여백) |

**Icon**

| Token | px |
|---|---|
| `icon-xs` | 12 |
| `icon-sm` | 16 |
| `icon-md` | 20 |
| `icon-lg` | 24 |
| `icon-xl` | 32 |

**Border**: `border-thin` 1 · `border-thick` 2

**Layout**

| Token | 값 | 설명 |
|---|---|---|
| `page-margin` | → `spacing-24` (24) | 모바일 좌우 기본 여백 (TDS와 같이 24) |
| `section-gap` | → `spacing-32` (32) | 섹션 사이 간격 |
| `screen-mobile` | 375 | 모바일 기준 폭 |

**Component** (컴포넌트 전용 토큰)

| Token | 값 | 설명 |
|---|---|---|
| `field-height-s` | → `height-md` (40) | 입력·스테퍼 S |
| `field-height-m` | → `height-lg` (48) | 입력창·Select·Input Button 기본 (최소 터치 영역) |
| `field-height-l` | → `height-xl` (56) | 입력창·Select·Input Button 큰 크기 |
| `row-height` | → `height-lg` (48) | 목록·메뉴·피커·달력처럼 줄 단위로 누르는 영역 |
| `button-height-m` | 38 | Button M 높이 (TDS) |
| `button-padding-s` | 10 | Button S 좌우 여백 (TDS) |
| `button-padding-xl` | 28 | Button XL 좌우 여백 (TDS) |
| `badge-height-s` | 20 | Count Badge S 높이·최소 폭 |
| `badge-height-m` | → `height-2xs` (24) | Badge M 높이 |
| `badge-height-l` | 28 | Badge L 높이 |
| `control-radius-32` | → `radius-sm` (8) | 높이 32 컨트롤 모서리 |
| `control-radius-38` | → `radius-10` (10) | 높이 38 컨트롤 모서리 |
| `control-radius-40` | → `radius-md` (12) | 높이 40 컨트롤 모서리 |
| `control-radius-48` | → `radius-14` (14) | 높이 48 컨트롤 모서리 |
| `control-radius-56` | → `radius-lg` (16) | 높이 56 컨트롤 모서리 |
| `segmented-height-s` | 38 | Segmented Control S 높이 |
| `segmented-inset-s` | 3 | Segmented Control S 안쪽 여백 |
| `segmented-radius-s` | → `radius-10` (10) | Segmented S 바깥 틀 |
| `segmented-item-radius` | → `radius-10` (10) | Segmented M 안쪽 칸 = 바깥 14 − 여백 4 |
| `segmented-item-radius-s` | → `radius-sm` (8) | Segmented S 안쪽 칸 |
| `switch-width-m` | 50 | Switch M 트랙 폭 (TDS) |
| `switch-width-l` | 56 | Switch L 트랙 폭 |
| `switch-height-m` | 30 | Switch M 트랙 높이 (TDS 50×30) |
| `switch-inset` | 3 | Switch 트랙 안쪽 여백 |
| `dialog-width` | 320 | Alert Dialog 폭 |
| `handle-width` | 40 | 바텀시트 핸들 폭 |
| `handle-height` | 4 | 바텀시트 핸들·슬라이더 트랙 두께 |
| `menu-width` | 240 | Menu 기본 폭 |
| `sheet-radius` | 28 | 바텀시트 위 모서리 (TDS) |
| `result-asset-size` | 60 | Result 아이콘 원 크기 (TDS) |
| `tab-height-l` | 51 | Tab L 높이 (TDS) |
| `tab-height-s` | 38 | Tab S 높이 |
| `tab-padding-fluid` | 8 | Tabs Fluid 왼쪽 여백 — 설명은 "14 (TDS)" |
| `quantity-icon-m` | 18 | Quantity Picker M 아이콘 (SEED medium) |


### 1.4 Effects

그림자는 아껴 쓴다. 면의 구분은 배경색(Background/Lower ↔ Default) 차이로 먼저 하고, **떠 있는 요소에만** 그림자를 쓴다.

**Figma 효과 스타일 (6개)** — 스타일에 실제로 들어 있는 값:

| Style | 쓰는 곳 | 효과 | 색 |
|---|---|---|---|
| Shadow/Small | 카드 · 작은 떠 있는 요소 | Drop shadow `0 1 / blur 4` + `0 2 / blur 8` | `#001B37` @10% |
| Shadow/Medium | 메뉴 · 스낵바 · FAB | Drop shadow `0 4 / blur 16` | `#001B37` @10% |
| Shadow/Large | 다이얼로그 · 바텀시트 | Drop shadow `0 8 / blur 32` | `#001D3A` @18% |
| Focus/Ring | 키보드 포커스 링 (웹) | Drop shadow `0 0 / blur 0 / spread 3` | `#298DFF` @47% (설명: "ORSO Blue 35%") |
| Blur/Toast | 토스트 배경 흐림 | Background blur 30 | — |
| Blur/Toast Top | 상단 토스트 | Background blur 30 + Drop shadow `0 2 / blur 30` | `#001B37` @10% |

그림자 색은 Semantic `Shadow/*` 변수에 연결돼 있다: Shadow/Small → `Shadow/Tiny`, Shadow/Medium → `Shadow/Weak`, Shadow/Large → `Shadow/Medium` (1.1.1 참고). Light 값은 위 표, Dark 값은 모두 `#000000` @50%.

> Effects 문서 페이지에는 투명도가 Small 6% · Medium 10% · Large 14% · Focus Blue 35%로 적혀 있어 실제 스타일 값(위 표)과 다르다. 부록 참고.

### 1.5 Icons

24px 그리드의 **둥근 면(fill) 아이콘 349개**. 선 아이콘은 쓰지 않는다. Material Symbols Rounded(Apache 2.0)를 바탕으로 했고, 금융 아이콘은 넣지 않았다(결제용 `credit-card`만 남김). 색은 Vector 칠을 `Semantic/Icon/*` 변수로 바꿔 쓰고, 컬러·3D 아이콘은 ORMO Icon Maker 플러그인으로 만든다.

| 카테고리 | 개수 | 아이콘 |
|---|---|---|
| 기본 · Core | 34 | chevron-left, chevron-right, chevron-down, chevron-up, arrow-left, close, plus, minus, check, search, menu, more-horizontal, more-vertical, home, user, bell, heart, star, info, alert-circle, check-circle, calendar, clock, camera, image, share, edit, trash, eye, paperclip, thumbs-up, message, map-pin, loader |
| 화살표·이동 · Arrows | 49 | arrow-right, arrow-up, arrow-down, arrow-back-ios, arrow-forward-ios, arrow-up-right, arrow-left-right, arrow-up-down, chevron-double-left/right/up/down, caret-down/up/left/right, caret-up-down, arrow-circle-left/right/up/down, first-page, last-page, arrow-to-top, arrow-to-bottom, expand, collapse, trending-up, trending-down, refresh, sync, sync-off, undo, redo, replay, repeat, shuffle, rotate, enter, indent-arrow, open-in-new, login, logout, door-open, cursor, cursor-click, panel-left, panel-right, navigation |
| 기본 동작 · Actions | 46 | close-circle, plus-circle, minus-circle, plus-square, minus-square, check-square, check-indeterminate, more-circle, apps, drag-handle, drag-horizontal, zoom-in, zoom-out, copy, share-nodes, link, link-off, download, upload, cloud-download, cloud-upload, filter, tune, sort, settings, lock, unlock, pin, unpin, bookmark, heart-broken, star-half, thumbs-down, eye-off, send, block, power, flash, flash-off, print, scissors, crop, qr-code, qr-scan, barcode, barcode-scan |
| 상태·알림 · Status | 25 | warning, help-circle, question, bell-off, bell-ring, megaphone, siren, hourglass, alarm, timer, history, calendar-month, calendar-check, calendar-x, verified, badge, medal, trophy, crown, diamond, star-circle, sparkle, fire, bolt, flag |
| 사람·보안 · People | 21 | user-plus, user-check, user-off, users, user-square, user-circle, user-pin, smile, baby, headset, headphones, brain, shield, shield-check, shield-user, shield-plus, shield-off, key, password, fingerprint, id-card |
| 소통 · Communication | 21 | chat, chat-dots, chat-question, forum, chat-off, phone, phone-off, mail, mail-open, inbox, at, smartphone, smartphone-landscape, fax, mic, mic-off, volume, volume-off, wifi, wifi-off, antenna |
| 미디어·문서 · Media | 25 | camera-off, gallery, video, video-off, movie, play, play-circle, pause, stop, music, document, document-lines, document-check, document-file, contract, folder, folder-star, memo, book, book-open, newspaper, grid, table, code, terminal |
| 편집·텍스트 · Editing | 14 | text, italic, underline, strikethrough, list-bullet, list-number, indent, quote, subtitles, translate, language, hashtag, paint, shapes |
| 장소·교통 · Places | 32 | store, store-alt, building, office, factory, church, hospital, pharmacy, map, location-off, my-location, compass, globe, car, taxi, motorcycle, bike, scooter, subway, train, plane, ship, sailboat, truck, delivery, luggage, gas-station, traffic, road, park, attractions, umbrella |
| 음식·카페 · Food | 16 | coffee, coffee-mug, coffee-maker, tea, takeout, bakery, cake, cookie, icecream, restaurant, rice-bowl, fruit, drink, beer, table-restaurant, smoking |
| 쇼핑·주문 · Commerce | 15 | cart, cart-add, bag, basket, tag, loyalty, gift, ticket, coupon, receipt, box, stamp, percent, pos, credit-card |
| 생활·기기 · Life | 18 | computer, desktop, keyboard, lightbulb, sofa, chair, laundry, hanger, clothes, shoes, briefcase, school, construction, build, chip, calculator, infinity, equal |
| 자연·날씨 · Nature | 14 | sun, moon, sunrise, snow, fog, rain, water-drop, tree, leaf, grass, flower, paw, footprint, rocket |
| 건강·과학 · Health | 11 | medical, pill, syringe, stethoscope, tooth, lung, heart-pulse, mask, virus, science, dna |
| 여가·기타 · Leisure | 8 | game, basketball, golf, baseball, dice, robot, donation, celebration |

> 카테고리별 개수 합계 = 349.


---

## 2. Actions

### 2.1 Action Button

사용자가 행동을 실행하는 기본 버튼. 화면에서 가장 중요한 행동 하나에만 Solid를 쓰고, 나머지는 Weak · Outline · Ghost로 위계를 낮춘다. · Mobile · Web · v1.0

**컴포넌트**: Action Button (128 variants) · Action Button / Icon Only (96 variants, 정사각 아이콘 버튼 — 접근성 라벨 필수)

**Anatomy**: ① Container (Height · Padding · Radius · Fill 토큰) ② Prefix Icon (선택, 교체 가능) ③ Label (Text 스타일 · Text/* 색) ④ Suffix Icon (선택, 주로 chevron-right)

**Size spec**

| Size | Height | Padding X | Gap | Radius | Text style | Icon |
|---|---|---|---|---|---|---|
| S | `height-xs` 32 | `spacing-12` | `spacing-4` | `control-radius-32` 8 | Body sm/Semibold | `icon-sm` 16 |
| M | `height-md` 40 | `spacing-16` | `spacing-4` | `control-radius-40` 12 | Body md/Semibold | `icon-md` 20 |
| L | `height-lg` 48 | `spacing-20` | `spacing-8` | `control-radius-48` 14 | Body md/Semibold | `icon-md` 20 |
| XL | `height-xl` 56 | `spacing-24` | `spacing-8` | `control-radius-56` 16 | Body lg/Semibold | `icon-lg` 24 |

**Color spec**

| Variant | Fill | Pressed | Label / Icon | Border |
|---|---|---|---|---|
| Brand Solid | Fill/Brand | Fill/Brand + Fill/Pressed | Text/On Fill | — |
| Brand Weak | Fill/Brand Weak | Fill/Brand Weak + Fill/Pressed | Text/Brand | — |
| Neutral Solid | Fill/Neutral | Fill/Neutral + Fill/Pressed | Text/On Fill | — |
| Neutral Weak | Fill/Neutral Weak | Fill/Neutral Weak + Fill/Pressed | Text/Primary | — |
| Critical Solid | Fill/Danger | Fill/Danger + Fill/Pressed | Text/On Fill | — |
| Critical Weak | Fill/Danger Weak | Fill/Danger Weak + Fill/Pressed | Text/Danger | — |
| Outline | 없음 | Fill/Pressed | Text/Primary | Grey Opacity 300 |
| Ghost | 없음 | Fill/Pressed | Text/Primary | — |
| Disabled (공통) | Fill/Neutral Weak | — | Text/Quaternary | Border/Default |

**Properties**

| Property | Type | Values | 설명 |
|---|---|---|---|
| Variant | Variant | Brand Solid · Brand Weak · Neutral Solid · Neutral Weak · Critical Solid · Critical Weak · Outline · Ghost | 강조 수준과 의미 |
| Size | Variant | S · M · L · XL | 높이 32 · 40 · 48 · 56 |
| State | Variant | Enabled · Pressed · Disabled · Loading | Loading 중엔 라벨을 숨기고 폭 유지 (Icon Only는 Loading 없음) |
| Label | Text | 버튼 | 짧은 동사형 (저장, 보내기) |
| Prefix / Suffix Icon | Boolean | false (기본) | 앞·뒤 아이콘 표시 |
| Prefix / Suffix Icon Swap | Instance swap | Icon/* | 아이콘 교체 (Count Badge도 가능) |

**Size guide**

| Size | 높이 | 플랫폼 | 쓰는 곳 |
|---|---|---|---|
| XL | 56 | Mobile | 하단 CTA · 화면의 주요 행동 |
| L | 48 | Mobile · Web | 모바일 본문 버튼 · 웹 주요 버튼 |
| M | 40 | Web | 웹 기본 버튼 · 모바일 보조 버튼 |
| S | 32 | Web | 표·카드 안 인라인 버튼 |

**Usage**
- 한 영역의 버튼 묶음은 최대 2개 — 주요 1개(Solid) + 보조 1개(Weak · Outline · Ghost).
- 하단 고정 CTA는 XL, 화면 안 일반 버튼은 L 또는 M, 리스트·카드 안에서는 S.
- 되돌릴 수 없는 삭제·해지에만 Critical.
- 라벨은 2~6자 동사형으로 짧게. 아이콘은 의미를 더할 때만.
- 아이콘만 있는 버튼은 접근성 라벨이 반드시 필요하고, 터치 영역은 최소 44px.

### 2.2 Bottom CTA

화면 맨 아래에 고정되는 주요 행동 영역. 버튼 1~2개와, 필요하면 위에 동의·안내를, 아래에 보조 행동을 둔다. · **Mobile 전용** · v1.0

**구성**: Bottom CTA · Bottom CTA / Button Area (Buttons × Weak, 5 variants) · Bottom CTA / Upper Item (3 variants)

**조합 예시**: 버튼 1개 + 동의 체크 · 버튼 2개 + 보조 행동 · 세로 2개 + 안내 문구

**Spec**

| Part | Token |
|---|---|
| Width | 화면 폭 (모바일 375 기준, FILL) |
| Top Fog | Scroll Fog · Placement=Bottom (스크롤 내용과 이어지는 흐림) |
| Container | Background/Default · 아래 여백 `spacing-20` |
| Upper Item | 좌우 `spacing-24` · 아래 `spacing-16` · Checkbox L / Ghost S 버튼 / Body sm/Medium · Text/Secondary |
| Button Area | 좌우 `spacing-20` · 버튼 사이 `spacing-8` · Action Button XL 56 (`control-radius-56` 16) |
| Lower Item | 위 `spacing-8` · Action Button Ghost M 가운데 정렬 |

**Properties**

| Property | Type | Values / Default | 설명 |
|---|---|---|---|
| Show Upper Item | Boolean | true | 버튼 위 보조 영역 |
| Show Lower Item | Boolean | false | 버튼 아래 보조 행동 |
| Button Area › Buttons | Variant (중첩) | 1 · 2 · 2 (Vertical) | 버튼 수와 방향 |
| Button Area › Weak | Variant (중첩) | Brand · Neutral | 보조 버튼 색 |
| Upper Item › Component | Variant (중첩) | Checkbox · Text Button · Description | 보조 영역 종류 |

**Size guide**: 버튼 XL 56 · Mobile 전용. 앱 화면 하단 고정. 웹에서는 페이지 안 버튼(Action Button L/M)을 쓴다.

**Usage**
- 화면의 다음 단계로 가는 행동 하나를 둔다. 버튼이 2개면 오른쪽(세로면 위)이 주요 행동.
- 두 버튼 문구가 길어 한 줄에 안 들어가면 `2 (Vertical)`로 바꾼다.
- 동의가 필요하면 Upper Item › Checkbox를 쓰고, 체크 전에는 주요 버튼을 Disabled로 둔다.
- 키보드가 올라오면 키보드 바로 위에 붙고, 위쪽 흐림은 그대로 유지.

### 2.3 Top Navigation

화면 맨 위의 앱 바. 뒤로가기, 제목, 오른쪽 행동으로 구성하고, 탭 첫 화면은 큰 제목(Large)을 쓴다. · Mobile · v1.0

**Variants**: Layout(Center · Left · Large) × Theme(Default · Transparent) = 6 — Center: 가운데 제목 · Left: 왼쪽 제목 · Large: 큰 제목(탭 루트 화면) · Transparent: 이미지 위, 흰 아이콘

**Spec**

| Part | Token |
|---|---|
| Bar height | `height-xl` 56 |
| Padding X | `spacing-8` (아이콘 버튼 40 안에서 아이콘이 화면 끝과 16) |
| Icon button | `height-md` 40 · `icon-lg` 24 · Grey 900 (Transparent: Static White) |
| Title | Body lg/Bold · Text/Strong |
| Large title | Display xs/Bold · 좌우 `page-margin` · 아래 `spacing-12` |
| Text action | Body md/Semibold · Text/Brand |
| Background | Background/Default · Transparent는 없음 |

**Properties**

| Property | Type | Values / Default | 설명 |
|---|---|---|---|
| Back | Boolean | true | 뒤로가기 |
| Back Icon | Instance swap | Component | arrow-back-ios(<) · close |
| Title | Text | 텍스트 | 화면 제목 |
| Action 1 / Action 2 | Boolean | true | 오른쪽 아이콘 1 / 2 |
| Action 1 Icon / Action 2 Icon | Instance swap | Component | — |
| Text Action | Boolean | false | 오른쪽 텍스트 (완료·저장) |
| Text Action Label | Text | 텍스트 | 라벨 |
| Layout | Variant | Center · Left · Large | 제목 배치 |
| Theme | Variant | Default · Transparent | 배경 |

**Usage**
- 오른쪽 아이콘은 최대 2개. 더 필요하면 more 아이콘 → Menu Sheet로 묶는다.
- 모달처럼 아래에서 올라온 화면은 뒤로가기 대신 close 아이콘.
- 스크롤하면 Large 제목이 작아지며 Center로 바뀌는 패턴을 권장.

---

## 3. Inputs

### 3.1 Checkbox

여러 항목 중 0개 이상을 고르거나, 한 가지 설정을 켜고 끌 때 쓴다. 즉시 반영되는 설정 on/off는 Switch. · Mobile · Web · v1.0

**Variants**: Size(M · L) × State(Enabled · Disabled) × Checked(Unchecked · Checked · Indeterminate) = 12 (Shape는 Circle 하나뿐)

| Size | Control | Mark icon | Label | Gap |
|---|---|---|---|---|
| M | `icon-md` 20 | `icon-sm` 16 (`icon-md` 20) | Body sm/Regular | `spacing-8` |
| L | `icon-lg` 24 | `icon-md` 20 (`icon-lg` 24) | Body md/Regular | `spacing-8` |

| 상태 | Fill | Border | Mark |
|---|---|---|---|
| Unchecked | Grey 300 | — | Static White |
| Checked · Indeterminate | Fill/Brand | — | Static White |
| Disabled | Fill/Neutral Weak | Border/Default | Icon/Quaternary · Text/Quaternary |

Radius: `radius-full`

**Properties**: Label (Text, "선택 항목") · Show Label (Boolean, true) · Shape (Circle) · Size (M 20 · L 24) · Checked · State

**Size guide**: L 24 — Mobile, 목록·약관 동의 (줄 전체 누름 영역 48 이상) · M 20 — Web, 폼·표 안 선택

**Usage**
- 라벨까지 포함한 전체 행을 누를 수 있게 하고, 터치 영역은 최소 48px.
- "전체 동의"처럼 하위 항목 일부만 선택되면 Indeterminate.
- 모든 화면에서 **원형 체크박스 하나로 통일**한다 (약관 동의·목록·폼 모두).
- 하나만 고르는 경우엔 Radio.

### 3.2 Radio

여러 선택지 중 정확히 하나를 고를 때 쓴다. 같은 그룹 안에서는 하나만 켜진다. · Mobile · Web · v1.0

**Variants**: Size(M · L) × State(Enabled · Disabled) × Checked(Off · On) = 8 · Radio Group 예시 포함

| Part | M | L |
|---|---|---|
| Control | `icon-md` 20 | `icon-lg` 24 |
| Dot (On) | `spacing-8` 8 | `spacing-12` 12 |
| Label | Body sm/Regular | Body md/Regular |
| Gap | `spacing-8` | `spacing-8` |

| State | Fill | Border | Dot |
|---|---|---|---|
| Off | Background/Default | Grey Opacity 300 2px | — |
| On | Fill/Brand | — | Static White |
| Disabled | Fill/Neutral Weak | Border/Default | Icon/Quaternary |

**Properties**: Label ("선택 항목") · Show Label (true) · Size · Checked (Off · On) · State

**Size guide**: L 24 — Mobile 목록 선택 · M 20 — Web 폼·표 안 선택

**Usage**
- 선택지가 2~5개면 Radio, 6개 이상이면 Select, 2~4개를 한 줄에 보여주면 Segmented Control을 고려.
- 기본 선택값을 하나 정해두는 걸 권장.
- 설명이 긴 선택지는 Select Box(Radiomark).

### 3.3 Switch

설정을 즉시 켜고 끄는 토글. 누르는 순간 바로 반영되는 설정에만 쓰고, 저장 버튼이 필요한 폼에서는 Checkbox. · Mobile · Web · v1.0

**Variants**: Size(M · L) × State(Enabled · Disabled) × Checked(Off · On) = 8

| Part | M | L |
|---|---|---|
| Track | `switch-width-m` 40 × `icon-lg` 24 | `switch-width-l` 56 × `icon-xl` 32 |
| Thumb | `icon-sm` 16 | `icon-lg` 24 |
| Padding | `spacing-4` | `spacing-4` |
| Radius | `radius-full` | `radius-full` |
| Thumb effect | Shadow/Small | Shadow/Small |

| State | Track | Thumb |
|---|---|---|
| Off | Grey 300 | Fill/Inverse |
| On | Fill/Brand | Fill/Inverse |
| Disabled Off | Fill/Neutral Weak | Fill/Inverse |
| Disabled On | Fill/Brand Weak + Fill/Pressed | Fill/Inverse |

**Properties**: Label ("텍스트") · Show Label (false — 리스트에서는 List의 제목을 쓰고 숨김) · Size · Checked · State

**Size guide**: L 32(트랙) — Mobile 설정 목록 · M 24(트랙) — Web 폼·표 안 설정

**Usage**
- 리스트 오른쪽에 둘 때는 Switch 라벨을 숨기고 List 제목을 라벨로.
- 결과가 바로 반영되지 않는 선택에는 Switch 대신 Checkbox.
- 모바일 기본은 L, 촘촘한 웹 설정 화면은 M.

### 3.4 Chip

필터를 고르거나 키워드를 선택할 때 쓰는 둥근 버튼. 여러 개를 가로로 나열하고, 선택된 칩은 색으로 구분한다. · Mobile · Web · v1.0

**Variants**: Variant(Solid · Outline Strong · Outline Weak) × Size(S · M · L) × State(Enabled · Pressed · Selected · Disabled) = 36

| Size | Height | Padding X | Gap | Text | Icon | Radius |
|---|---|---|---|---|---|---|
| S | `height-xs` 32 | `spacing-12` | `spacing-4` | Body sm/Medium | `icon-sm` 16 | `radius-full` |
| M | `height-sm` 36 | `spacing-12` | `spacing-4` | Body sm/Medium | `icon-sm` 16 | `radius-full` |
| L | `height-md` 40 | `spacing-16` | `spacing-4` | Body sm/Medium | `icon-md` 20 | `radius-full` |

| Variant | Enabled | Pressed | Selected |
|---|---|---|---|
| Solid | Fill/Neutral Weak · Text/Primary | Fill/Neutral Weak + Fill/Pressed | Fill/Neutral · Text/On Fill |
| Outline Strong | Grey Opacity 300 · Text/Primary | Fill/Pressed | Fill/Neutral · Text/On Fill |
| Outline Weak | Border/Default · Text/Secondary | Fill/Pressed | Fill/Brand Weak · Blue 500 · Text/Brand |
| Disabled (공통) | Fill/Neutral Weak 또는 Border/Default · Text/Quaternary | — | — |

**Properties**: Label ("칩") · Prefix Icon (false) / Swap · Suffix Icon (false; chevron-down = 옵션 열기, close = 삭제) / Swap · Variant · Size (S 32 · M 36 · L 40) · State

**Size guide**: L 40 — Mobile 필터 바 · M 36 — Web 필터·선택 기본 · S 32 — Web 촘촘한 카드·표

**Usage**
- 한 줄로 가로 스크롤되게 나열하고, 칩 사이 간격은 `spacing-8`.
- 단일 선택 필터는 Solid, 여러 개를 동시에 고르는 키워드는 Outline Weak.
- 상세 비교가 필요한 선택은 Select Box, 행동을 실행하는 버튼은 Action Button.

### 3.5 Segmented Control

같은 층위의 보기 2~4개를 한 줄에서 바꿔 볼 때 쓴다. 선택된 칸은 흰 바탕과 그림자로 떠 보인다. · Mobile · Web · v1.0

**구성**: Segmented Control (Size × Segments 2·3·4칸 = 6) · Segmented Control / Item (Size × Selected × State = 8)

| Part | M | S |
|---|---|---|
| Container height | `height-lg` 48 | `segmented-height-s` 38 |
| Item height | `height-md` 40 | `height-xs` 32 |
| Container padding · gap | `spacing-4` · `spacing-4` | `segmented-inset-s` 3 · `spacing-4` |
| Radius (container / item) | `control-radius-48` 14 / `segmented-item-radius` 10 | `segmented-radius-s` 10 / `segmented-item-radius-s` 8 |
| Label | Body sm/Semibold | Body xs/Semibold |

- Container fill: Fill/Neutral Weak
- Selected item: Background/Default + Shadow/Small · Text/Strong
- Unselected item: Text/Tertiary

**Item properties**: Label ("항목") · Size (M · S) · Selected (False · True) · State (Enabled · Disabled)

**Size guide**: M 48 — Mobile 화면 상단 보기 전환 · S 38 — Web·카드 안 좁은 영역

**Usage**
- 칸은 2~4개까지. 5개 이상이면 Tabs나 Chip.
- 라벨은 2~4자로 짧게, 칸 너비는 모두 같게.
- 페이지 전체를 바꾸는 이동에는 Tabs, 같은 데이터의 보기 전환에는 Segmented Control.

### 3.6 Field

입력 컨트롤에 라벨, 필수·선택 표시, 도움말, 오류 메시지, 글자 수를 붙이는 래퍼. 폼에서는 Text Input · Textarea를 항상 Field로 감싸 쓴다. · Mobile · Web · v1.0

**Anatomy**: ① Label (Body sm/Semibold · Text/Secondary) ② Indicator (필수 `*` Text/Danger 또는 `(선택)`) ③ Control (Text Input · Textarea 인스턴스) ④ Description / Error (Body sm/Regular · 오류 시 Text/Danger + 아이콘) ⑤ Counter (글자 수, 선택)

**Variants**: Control(Text Input · Textarea) × State(Default · Invalid · Disabled) = 6

| Part | Token |
|---|---|
| Header ↔ Control ↔ Footer 간격 | `spacing-8` |
| Label ↔ Indicator 간격 | `spacing-4` |
| Error icon | `icon-sm` 16 · Icon/Danger |
| Label | Body sm/Semibold · Text/Secondary (Disabled: Text/Quaternary) |
| Description | Body sm/Regular · Text/Tertiary |
| Error message | Body sm/Regular · Text/Danger |
| Counter | Body sm/Regular · Text/Tertiary |

**Properties**: Control · State (Invalid는 Control도 Invalid로) · Label / Show Label · Indicator / Indicator Text (`*` · `(선택)`) · Description (Invalid에선 오류 메시지 직접 수정) · Show Footer · Counter / Counter Text (`0/20`)

**Usage**
- 폼의 모든 입력은 Field로 감싸 라벨을 보여준다. placeholder를 라벨 대신 쓰지 않는다.
- 필수가 대부분이면 선택 항목에만 "(선택)", 선택이 대부분이면 필수에만 "*".
- 오류 메시지는 무엇이 잘못됐고 어떻게 고치면 되는지 한 문장으로.
- Field 사이 간격은 `spacing-24`.

### 3.7 Text Input & Textarea

사용자가 텍스트를 직접 입력하는 컨트롤. 한 줄은 Text Input, 여러 줄은 Textarea. 라벨과 안내 문구가 필요하면 Field로 감싼다. · Mobile · Web · v1.0

**Anatomy**: ① Container ② Prefix Icon (선택, 검색 등) ③ Value / Placeholder (Body md(L) · Body sm(M)) ④ Suffix Text (단위: 원, kg) ⑤ Clear Button (Focused + 값 있을 때 노출)

**Variants**
- Text Input (36): Variant(Outline · Fill · Underline) × Size(M · L) × State(Enabled · Filled · Focused · Invalid · Disabled · Read Only)
- Textarea (10): Variant(Outline · Fill) × State(Enabled · Filled · Focused · Invalid · Disabled)

**Size spec**

| Size | Height | Padding X | Gap | Radius | Text style | Icon |
|---|---|---|---|---|---|---|
| M | `field-height-m` 48 | `spacing-12` (Underline 0) | `spacing-8` | `control-radius-48` 14 | Body sm/Regular | `icon-md` 20 |
| L | `field-height-l` 56 | `spacing-16` (Underline 0) | `spacing-8` | `control-radius-56` 16 | Body md/Regular | `icon-md` 20 |
| Textarea | min `height-textarea` 120 | `spacing-16` / 12 | `spacing-8` | `control-radius-48` 14 | Body md/Regular | — |

**State spec**

| State | Background (Outline / Fill) | Border | Text |
|---|---|---|---|
| Enabled | Background/Default / Fill/Neutral Weak | Grey Opacity 300 · 1px | Text/Quaternary |
| Filled | Background/Default / Fill/Neutral Weak | Grey Opacity 300 · 1px | Text/Primary |
| Focused | Background/Default / Fill/Neutral Weak | Blue 500 · 2px | Text/Primary |
| Invalid | Background/Default / Fill/Neutral Weak | Red 500 · 2px | Text/Primary |
| Disabled | Fill/Neutral Weak | Border/Default · 1px | Text/Quaternary |
| Read Only | Fill/Neutral Weak | Border/Default · 1px | Text/Primary |

**Properties**: Variant (Outline 기본 · Fill 회색 박스 · Underline 밑줄) · Size (M 48 · L 56) · State · Value (placeholder 기본 "내용을 입력해 주세요") · Prefix Icon / Swap · Suffix Text / Value ("원") · Clear Button (Focused에서는 항상 노출) · Suffix Icon / Swap (예: chevron-down) · (Textarea) Counter (true) / Counter Text ("0/500")

**Size guide**: L 56 — Mobile 기본 입력 · M 48 — Web 폼·필터, 한 화면에 입력이 많을 때

**Usage**
- 라벨·도움말·오류 메시지가 필요하면 Field로 감싼다. Text Input 단독은 검색창·인라인 편집처럼 라벨이 필요 없는 곳에만.
- 한 화면 안에서는 같은 Variant를 섞지 않는다. 폼은 Outline, 카드형 입력은 Fill, 금액·단계형 입력은 Underline.
- placeholder는 예시만 보여주고, 필수 정보는 라벨에 적는다.
- 오류는 빨간 테두리 + Field의 오류 메시지를 함께. 색만으로 상태를 알리지 않는다.
- 모바일에서는 iOS 확대를 막기 위해 L(16px 텍스트)을 기본으로.

### 3.8 Quantity Picker

수량을 하나씩 늘리거나 줄일 때 쓴다. 최소값에서는 빼기, 최대값에서는 더하기 버튼이 비활성으로 바뀐다. · Mobile · Web · **v1.1**

**구성**: Quantity Picker (Size × State = 8) · Quantity Picker Button (Type(Decrease · Increase) × Size × State(Enabled · Pressed · Focused · Loading · Disabled) = 20)

| Part | S | M |
|---|---|---|
| Height · 버튼 크기 | `height-sm` 36 (버튼 36×36) | `height-md` 40 (버튼 40×40) |
| Value | 좌우 `spacing-8` · 최소 폭 36 | 좌우 `spacing-8` · 최소 폭 36 |
| Icon | `icon-sm` 16 · Grey 900 | `quantity-icon-m` 18 · Grey 900 |
| Count | Body md/Medium · Text/Strong | Body md/Medium · Text/Strong |

- Container: Background/Default · Grey Opacity 300 1px · `radius-sm` 8 · 구분선 1×16 Grey Opacity 100
- Disabled: 바탕 그대로 · Icon/Quaternary · Text/Quaternary
- Pressed는 웹 hover와 같은 모양. 누르는 동안 버튼이 2px 작아진다. Loading 동안엔 다시 누를 수 없고, 최소·최대값에서는 Disabled.

**Properties**: Count (Text, 기본 3) · Size (S 36 · M 40) · State (Enabled · Min(− 비활성) · Max(+ 비활성) · Disabled) · Decrease / Increase (Quantity Picker Button 인스턴스 노출)

**Size guide**: M 40 — Mobile 상품 상세 수량 · S 36 — Web·목록, 장바구니 목록·표 안 수량

**Usage**
- 장바구니·인원 선택처럼 작은 범위(1~99)를 조절할 때. 큰 숫자는 Text Input.
- 최대 수량에 닿으면 + 버튼을 비활성하고 이유를 Snackbar로 알린다.
- 값을 직접 탭해서 입력하도록 개발할 수도 있다 (선택).

---

## 4. Data Display

### 4.1 Badge

상태나 속성을 짧게 알려주는 **누를 수 없는** 라벨. 누르는 동작이 필요하면 Chip 또는 Action Button을 쓴다. · Mobile · Web · v1.0

**Variants**: Tone(6) × Variant(3) × Size(2) = 36

**Spec**

| Size | Text | Height / Padding X | Gap | Radius | Icon |
|---|---|---|---|---|---|
| M | Body xs (Weak: Medium, 그 외 Bold) | `badge-height-m` 24 / `spacing-8` | `spacing-2` | `radius-full` 999 | `icon-xs` 12 |
| L | Body sm (Weak: Medium, 그 외 Bold) | `badge-height-l` 28 / `spacing-12` | `spacing-2` | `radius-full` 999 | `icon-sm` 16 |

| Tone | Weak (bg / text) | Solid (bg / text) | Outline (border / text) |
|---|---|---|---|
| Neutral | Fill/Neutral Weak / Text/Secondary | Fill/Neutral / Text/On Fill | Grey Opacity 300 / Text/Secondary |
| Brand | Fill/Brand Weak / Text/Brand | Fill/Brand / Text/On Fill | Blue 500 / Text/Brand |
| Informative | Teal 50 / Teal 700 | Teal 500 / Text/On Fill | Teal 400 / Teal 700 |
| Positive | Fill/Success Weak / Text/Success | Fill/Success / Text/On Fill | Green 400 / Text/Success |
| Warning | Fill/Warning Weak / Text/Warning | Fill/Warning / Text/On Fill Warning | Yellow 600 / Text/Warning |
| Critical | Fill/Danger Weak / Text/Danger | Fill/Danger / Text/On Fill | Red 500 / Text/Danger |

**Properties**

| Property | Type | Values / Default | 설명 |
|---|---|---|---|
| Label | Text | 배지 | 10자 이내 |
| Prefix Icon | Boolean | false | 라벨 앞 아이콘 |
| Prefix Icon Swap | Instance swap | Component | 아이콘 교체 |
| Tone | Variant | Neutral · Brand · Informative · Positive · Warning · Critical | 의미 |
| Variant | Variant | Weak · Solid · Outline | 강조 방식 |
| Size | Variant | M · L | M 12px · L 14px |

**Size guide (플랫폼별)**: L = 24 (Mobile, 카드·목록 강조) · M = 22 (Web, 표·촘촘한 목록)

**Usage**
- Neutral: 상태 없음 · Brand: 브랜드 강조(아껴서) · Informative: 베타·안내 · Positive: 완료·승인 · Warning: 만료 임박·누락 · Critical: 반려·실패.
- 리스트처럼 반복되는 곳은 Weak, 이미지 위는 Solid, 상세 본문은 Outline.
- 한 줄에 배지는 2개까지. 3개 이상이면 Tag Group을 고려한다.

### 4.2 Count Badge

버튼 안에서 담은 개수/선택 수를 숫자로 보여준다. Action Button의 아이콘 자리에 교체해 넣어 쓴다. · Mobile · Web · v1.0

**Variants**: Tone(Neutral · Brand) × Variant(Inverse · Solid) × Size(S · M) = 8

**Spec**

| Part | S | M |
|---|---|---|
| Height | `badge-height-s` 20 | `badge-height-m` 24 |
| Min width | 높이와 같음 (한 자리 = 원) | 높이와 같음 |
| Padding X | `spacing-4` | `spacing-8` |
| Count | Body xs/Bold | Body sm/Bold |
| Radius | `radius-full` | `radius-full` |
| Inverse | Fill/Inverse + 숫자 Fill/Neutral · Text/Brand | 같음 |
| Solid | Fill/Neutral · Fill/Brand + 숫자 Text/On Fill | 같음 |

**Properties**

| Property | Type | Values / Default | 설명 |
|---|---|---|---|
| Count | Text | 2 | 숫자만, 99 넘으면 99+ |
| Tone | Variant | Neutral · Brand / Neutral | 버튼 색과 같게 |
| Variant | Variant | Inverse · Solid / Inverse | Inverse = Solid 버튼 안 · Solid = Weak·Outline·Ghost 버튼 안 |
| Size | Variant | S · M / S | 버튼 S·M → S, L·XL → M |

**Usage**
- Action Button에서 Prefix 또는 Suffix Icon을 켜고, 아이콘 교체에서 Count Badge를 고른다.
- Solid 버튼 안엔 Inverse, Weak·Outline·Ghost 버튼 안엔 Solid. Tone은 버튼 색과 맞춘다.
- 숫자만 넣는다. 99 초과 시 `99+`, 0이면 아이콘을 꺼서 배지를 숨긴다. 배지만 따로 누를 수 없다.

### 4.3 Image Frame

상품·게시글 이미지를 일정한 비율과 모서리로 담는 틀. 이미지가 없거나 불러오지 못하면 Content Placeholder가 대신 보인다. · Mobile · Web · v1.0

**Variants**: Ratio(1:1 · 4:3 · 3:4 · 16:9) × Radius(None · Medium · Large) = 12

**Spec**

| Part | Token |
|---|---|
| Radius | None 0 · Medium `radius-md` 14 · Large `radius-lg` 16 |
| Stroke | Border/Default · `border-thin` · inside |
| Fallback | Content Placeholder / Default |
| 크기 | 폭은 레이아웃에 맞춰 늘리고 비율 유지 (Shift 리사이즈) |

**Properties**: Stroke (Boolean, true) · Ratio (Variant) · Radius (Variant)

**Usage**
- 상품 그리드 1:1, 피드 카드 4:3, 배너 16:9, 세로 사진 3:4.
- 리스트 썸네일은 Medium, 큰 카드 이미지는 Large, 화면 꽉 찬 이미지는 None.
- 이미지 채움은 Image 레이어(인스턴스)에 넣는다. 프레임 자체에 넣으면 선이 가려진다.

### 4.4 List

목록과 설정 화면의 기본 행. 앞·제목·설명·뒤 슬롯을 켜고 끄고 교체해 대부분의 리스트를 만든다. · Mobile · Web · v1.0

**구성 컴포넌트**: List Item (6 variants: Lines × State) · List Header (Large / Small) · List Item / Leading (Type × Size, 9 variants)

**Spec**

| Part | Token |
|---|---|
| Padding X | `page-margin` 20 |
| Padding Y | 1줄 `spacing-12` · 2줄 `spacing-16` |
| Leading ↔ Content gap | `spacing-12` |
| Title | Body md/Medium · Text/Primary |
| Description | Body sm/Regular · Text/Tertiary · 제목과 `spacing-2` |
| Trailing Text | Body md/Regular · Text/Secondary |
| Chevron | `icon-md` 20 · Icon/Tertiary |
| Pressed | Fill/Pressed |
| Header Large | Body lg/Bold · 위 `spacing-24` |
| Header Small | Body sm/Semibold · Text/Tertiary · 위 `spacing-16` |

**Leading 종류**: Icon · Icon Circle · Icon Square · Avatar (크기 24 / 32 / 40, 아이콘 34종)

**Properties · List Item**

| Property | Type | Values / Default | 설명 |
|---|---|---|---|
| Leading | Boolean | true | 앞 슬롯 표시 |
| Leading › Type · Size · Icon | Variant · Instance swap (중첩) | Icon · Icon Circle · Icon Square · Avatar | 종류 · 크기 24/32/40 · 아이콘 34종 |
| Title | Text | 텍스트 | 제목 |
| Description | Text | 동해물과 백두산이 마르고 닳도록 | 설명 (Lines=2) |
| Trailing Text | Boolean | false | 오른쪽 텍스트 |
| Trailing Text Value | Text | 1,000원 | — |
| Trailing Control | Boolean | false | 오른쪽 컨트롤 |
| Trailing Control Swap | Instance swap | Component | Switch · Checkbox · Radio · Badge · Action Button |
| Chevron | Boolean | true | 이동 표시 |
| Lines | Variant | 1 · 2 | 1줄 · 2줄 |
| State | Variant | Enabled · Pressed · Disabled | 상태 |

**List Header 속성**: Title (Text) · Action (Boolean, true) · Action Text (Text) · Size (Large · Small)

**Usage**
- 다른 화면으로 이동하는 행에는 Chevron, 그 자리에서 값이 바뀌는 행에는 Trailing Control. 둘을 함께 쓰지 않는다.
- 행 사이 구분선은 Divider Hairline Inset.
- 섹션 사이는 List Header로 묶고, 섹션 간 간격은 Divider Thick 또는 `spacing-24`.

### 4.5 Divider

콘텐츠 사이를 나누는 선. 같은 묶음 안은 Hairline, 서로 다른 섹션 사이는 Thick. · Mobile · Web · v1.0

| Type | Color | Thickness | Inset |
|---|---|---|---|
| Hairline | Border/Default | `border-thin` 1 | 0 |
| Hairline Inset | Border/Default | `border-thin` 1 | `page-margin` 20 |
| Thick | Background/Lower | `spacing-8` 8 | 0 |
| Vertical | Border/Default | `border-thin` 1 (높이 `icon-md` 20) | — |

**Properties**: Type (Variant) = Hairline · Hairline Inset · Thick · Vertical

**Usage**
- 리스트 아이템 사이는 Hairline Inset, 화면 끝까지 닿아야 할 때만 Hairline.
- 섹션 사이는 Thick로 크게 끊는다. 여백만으로 구분되면 선을 생략.
- 메타 정보(지역·시간·조회수) 사이는 Vertical 또는 Tag Group의 구분점.

### 4.6 Store Card

매장 목록에서 매장 하나를 보여주는 카드. 이름·영업 상태·주소·거리와 도보 시간·사진을 한 줄에 담는다. · **Mobile 전용** · v1.0 (UIUX 1.1.1에서 옮겨 옴)

**Variants**: State(영업중 · 잠시 쉬어요 · 영업 종료) = 3

| Part | 값 |
|---|---|
| 패딩 / 간격 | 16 / 20 · 간격 12 |
| 사진 | 90 · `radius-sm` |
| 영업중 | Text/Brand |
| 잠시 쉬어요 | Text/Warning (재개 시각 표시) |
| 영업 종료 | 내용 50% 흐리게 (메뉴는 볼 수 있음) |

**Properties**

| Property | Type | Default / Values | 설명 |
|---|---|---|---|
| State | Variant | 영업중 · 잠시 쉬어요 · 영업 종료 | 영업 상태 |
| Store Name | Text | 을지대학교 범석관 카페 | 매장 이름 |
| Address | Text | (예: 경기도 성남시 …) | 주소, 최대 2줄 |
| Distance · Walk Time | Text | 910m · 14분 | 거리 · 도보 시간 |
| Show Distance | Boolean | true | 위치 권한이 없으면 끈다 |
| Show Image | Boolean | true | 매장 사진이 없으면 끈다 (글자 영역이 넓어짐) |

**Usage**
- 카드 전체가 버튼 하나다 → 누르면 그 매장 메뉴 홈. 장바구니에 다른 매장 메뉴가 있으면 매장 변경 시트를 먼저 띄운다.
- 영업 종료 매장도 목록에서 빼지 않고 흐리게 보여준다 (메뉴는 볼 수 있음).
- 상태는 색만이 아니라 글자로도 알린다 (영업중 · 잠시 쉬어요 · 영업 종료).
- 카드 사이는 Divider(Hairline)로 나눈다.

### 4.7 Menu Card

메뉴 목록에서 메뉴 하나를 보여주는 카드. 뱃지·이름·가격·설명을 담고, 사진은 MVP 여유가 있을 때만 켠다. · **Mobile 전용** · v1.0 (UIUX 2.1.1에서 옮겨 옴)

**Variants**: Image(False · True) × State(Default · Sold Out) = 4

| Part | 값 |
|---|---|
| 패딩 / 간격 | 20 / 12 |
| 사진 (Image=True) | 오른쪽 108 · `radius-14` |
| Sold Out | 내용 50% 흐리게 + 품절 뱃지, 누를 수 없음 |
| 설명 | 최대 2줄, 넘으면 … |

**Properties**: Menu Name (아메리카노) · Price (4,000원) · Description (깔끔하고 산뜻한 기본 커피에요) · Show Badge (Boolean, true — Badge 인스턴스가 노출돼 카드에서 바로 Tone·글자 변경) · Image (False 기본 · True) · State

**Usage**
- 카드 전체가 버튼 하나다 → 누르면 옵션 선택(2.2.1). 옵션 없는 메뉴는 바로 담고 토스트.
- 뱃지는 하나만: 품절 > 품절 임박 > 신규 > 인기.
- 사진 모드는 매장 메뉴에 사진이 모두 있을 때만 (일부만 있으면 전부 사진 없이).
- 카드 사이는 Divider(Hairline)로 나눈다.

---

## 5. Feedback

### 5.1 Callout

콘텐츠 사이에서 꼭 알아야 할 안내/주의 사항을 강조하는 상자. 화면 흐름 안에 놓이며, 화면 맨 위 고정 알림은 Page Banner. · Mobile · Web · v1.0

**Variants**: Tone(6) × Interaction(3) = 18

**Spec**

| Part | Token |
|---|---|
| Container | padding `spacing-16` / `spacing-12` · gap `spacing-8` · `radius-lg` 16 |
| Icon | `icon-md` 20 · Tone 아이콘 색 |
| Title | Body sm/Bold · Tone 텍스트 색 |
| Description | Body sm/Regular · Text/Secondary |
| Link | Body sm/Semibold · 밑줄 · Tone 텍스트 색 |
| Close | `icon-md` 20 |

| Tone | Background | Title · Icon |
|---|---|---|
| Neutral | Fill/Neutral Weak | Text/Primary · Icon/Secondary |
| Informative | Teal 50 | Teal 700 · Teal 600 |
| Positive | Fill/Success Weak | Text/Success · Icon/Success |
| Warning | Fill/Warning Weak | Text/Warning · Icon/Warning |
| Critical | Fill/Danger Weak | Text/Danger · Icon/Danger |
| Magic (AI) | Purple 50 | Purple 600 · Purple 500 |

**Properties**: Prefix Icon (Boolean, true) · Title (Boolean, true) · Title Text · Description · Link Text · Tone (Neutral · Informative · Positive · Warning · Critical · Magic) · Interaction (Default · Actionable · Dismissible)

**Usage**
- 한 화면에 Callout은 1~2개만.
- 문구는 2줄 이내, 더 긴 설명은 링크로 연결.
- 시스템 전체 공지는 Page Banner, 잠깐 보여주는 결과 알림은 Snackbar.

### 5.2 Snackbar

방금 한 행동의 결과를 화면 아래에 잠깐(3~5초) 보여주는 알림. 몇 초 뒤 저절로 사라지고 필요하면 되돌리기 같은 행동을 하나 붙인다. · Mobile · Web · v1.0

**Variants**: Position(Bottom · Top) × Variant(Default · Positive · Critical) × Action(False · True) = 9 (정의된 조합)

**Spec**

| Part | Token |
|---|---|
| Container | Fill/Neutral + Blur/Toast · `radius-full` · padding `spacing-12` / `spacing-20` · gap `spacing-12` |
| Width | 내용만큼(알약형) · 최대 화면 폭 − `spacing-16` × 2 |
| Message | Body md/Semibold · Text/On Fill (Top은 Text/Primary) · 한 줄 |
| Action | Fill/Inverse Weak 알약 · padding `spacing-4` / `spacing-12` · Body sm/Semibold · Text/On Fill |
| Icon | `icon-lg` 24 · Icon/Success · Icon/Danger |
| 위치 | Bottom: 하단 고정 요소 위 `spacing-16` · Top: 상단바 아래 `spacing-8` |

**Properties**: Position (Bottom: 어두운 반투명·행동 가능 / Top: 밝은 반투명·알림만) · Message · Action Text · Variant · Action

**Usage**
- "~했어요"처럼 결과를 한 줄로 짧게. 확인이 필요한 중요한 내용은 Alert Dialog.
- 행동은 하나만 (되돌리기, 보러가기).
- 동시에 하나만 보여주고, 새 알림이 오면 이전 것을 교체.

### 5.3 Result

일이 끝났거나, 보여줄 게 없거나, 문제가 생겼을 때 화면 가운데에서 결과를 알린다. 다음 할 일이 있으면 버튼으로 잇는다. · Mobile · Web · v1.0

**Variants**: Type(Success · Error · Empty) × Action(None · Single · Double) = 9

| 요소 | 값 | 토큰 |
|---|---|---|
| 여백 | 위 32 · 좌우·아래 40 · 요소 사이 20 | `spacing-32` · `spacing-40` · `spacing-20` |
| 아이콘 원 | 60 × 60, 완전 둥글게 | `Component/result-asset-size` · `radius-full` |
| 아이콘 | 32 (Success Brand · Error Danger · Empty Tertiary) | `icon-xl` · Icon/Brand · Icon/Danger · Icon/Tertiary |
| 원 배경 | Success Brand Weak · Error Danger Weak · Empty Neutral Weak | Fill/Brand Weak · Fill/Danger Weak · Fill/Neutral Weak |
| 제목 | Body lg/Semibold, 가운데 | Text/Strong |
| 설명 | Body md/Regular, 가운데 · 제목과 4 | Text/Secondary · `spacing-4` |
| 버튼 | Action Button M · 글과 16 · 버튼 사이 8 | Neutral Weak + Brand Solid |

**Properties**: Type · Action · Title (Text) · Description (Text) · Show Description (Boolean)

**Usage**
- 화면 전체가 결과 하나를 말할 때 (주문 완료, 빈 목록, 불러오기 실패).
- 제목은 무슨 일이 생겼는지 한 줄, 설명은 다음에 할 일을 짧게.
- 버튼은 다음 행동이 있을 때만. 두 개면 왼쪽이 보조, 오른쪽이 주 버튼.
- 잠깐 알려주고 끝나는 결과는 Snackbar.

### 5.4 Skeleton

콘텐츠를 불러오는 동안 실제 레이아웃과 같은 자리에 회색 뼈대를 보여준다. 반짝임(shimmer) 애니메이션은 개발에서 적용. · Mobile · Web · v1.0

**Types**: Rectangle · Circle · Text · List Item · Card

| Part | Token |
|---|---|
| Fill | Fill/Neutral Weak |
| Rectangle radius | `radius-md` 14 (이미지·카드) |
| Text | 높이 `icon-sm` 16 (본문) · `icon-xs` 12 (캡션), `radius-xs` |
| Circle | `radius-full` · 아바타 크기와 동일 |
| List Item | `page-margin` 20 · 행 간 `spacing-12` · 줄 간 `spacing-8` |

**Usage**
- 실제 콘텐츠와 같은 크기·위치로 배치해 로딩 후 레이아웃이 움직이지 않게 한다.
- 텍스트 마지막 줄은 짧게(60~70%).
- 같은 화면에서 Skeleton과 Progress Circle을 함께 쓰지 않는다.

### 5.5 Content Placeholder

이미지/콘텐츠를 불러오지 못했을 때 그 자리를 채우는 회색 대체 그래픽. Image Frame의 기본 상태. · Mobile · Web · v1.0

**Types**: Default(이미지) · Post(게시글) · Place(장소) · Product(상품) · Profile(프로필) · Error(로딩 실패)

| Part | Token |
|---|---|
| Root | Fill/Neutral Weak |
| Asset | Icon/Tertiary · `icon-xl` 32 · 가운데 고정 |
| 크기 | 부모(Image Frame 등)에 맞춰 자유롭게 |

**Usage**
- 보통 직접 쓰지 않고 Image Frame 안에서 이미지가 없을 때 자동 표시.
- 로딩 중 = Skeleton, 로딩 실패·이미지 없음 = Content Placeholder.
- 사람 프로필 자리는 Avatar(Identity Placeholder).

### 5.6 Progress Circle

작업이 진행 중임을 알리는 원형 로딩 표시. 회전 애니메이션은 개발에서 적용. 굵기는 지름의 1/8. · Mobile · Web · v1.0

**Variants**: Tone(Brand · Neutral · On Fill) × Size(S · M · L) = 9

| Tone | Track | Range |
|---|---|---|
| Brand | Fill/Brand Weak | Fill/Brand |
| Neutral | Fill/Neutral Weak | Icon/Secondary |
| On Fill | Static White Opacity 500 | Static White |

| Size | Token | 쓰임 |
|---|---|---|
| S | `icon-sm` 16 | 버튼 S·M · Reaction Button · 인라인 |
| M | `icon-lg` 24 | 버튼 L·XL · 리스트 더보기 |
| L | `icon-xl` 32 | 화면 전체 로딩 |

**Usage**
- 1초 이상 걸리는 작업에만. 콘텐츠 영역 로딩은 Skeleton 우선.
- 진한 채움 버튼 위에서는 On Fill, 흰 배경에서는 Brand 또는 Neutral.
- 화면 전체 로딩은 L을 가운데에 하나만.

### 5.7 Scroll Fog

스크롤 영역의 끝을 배경색으로 흐리게 덮어 "더 볼 내용이 있다"는 걸 알린다. · Mobile · Web · v1.0

**Placement**: Top · Bottom · Left · Right

| Part | Token |
|---|---|
| Fog Color | Background/Default (부모 배경에 맞춰 Background/Lower 등으로 교체) |
| 두께 | `spacing-40` |
| Mask | 선형 그라데이션 불투명 → 투명 (마스크 전용 값, 색에 영향 없음) |

**Usage**
- 스크롤할 수 있는 방향의 끝에만 붙이고, 끝까지 스크롤하면 숨긴다.
- Fog Color는 바로 아래 배경과 같은 토큰을 쓴다.
- 아래 요소도 눌릴 수 있도록 개발에서 `pointer-events`를 끈다.

### 5.8 Alert Dialog

중요한 결정 전에 흐름을 멈추고 한 번 더 확인하는 대화상자. 꼭 필요한 순간에만. · Mobile · Web · v1.0

**Variants**: Tone(Neutral · Critical) × Layout(Horizontal · Vertical · Single) = 6

| Part | Token |
|---|---|
| Container | `dialog-width` 320 · Background/Floated · `radius-2xl` 24 · Shadow/Large |
| Padding | 위·좌우 `spacing-24` · 아래 `spacing-16` |
| Content ↔ Footer | `spacing-24` |
| Title | Body xl/Bold · Text/Strong |
| Description | Body md/Regular · Text/Secondary · 제목과 `spacing-8` |
| Buttons | Action Button L · 간격 `spacing-8` |
| Dim | Background/Dim |

Tone: Neutral(Brand Solid) · Critical(Critical Solid, 되돌릴 수 없는 행동). Layout: Horizontal(2버튼 나란히) · Vertical(세로, 긴 라벨) · Single(확인만).

**Usage**
- 제목은 질문형(~할까요?), 버튼 라벨은 행동 그대로(삭제·나가기). "확인/예"는 피한다.
- 오른쪽(또는 위)이 주요 행동, 왼쪽(또는 아래)이 취소.
- 되돌릴 수 없는 행동에만 Critical. 단순 안내는 Snackbar.
- 바깥(Dim)을 눌러 닫을 수 있게 하되, Critical은 버튼으로만 닫는다.

---

## 6. Overlays

### 6.1 Bottom Sheet

화면 아래에서 올라와 현재 맥락을 유지한 채 선택·필터·짧은 입력을 하게 한다. 모바일에서 가장 많이 쓰는 오버레이. · Mobile · v1.0

**Variants**: Header Align(Left · Center) × Footer(None · Single · Double) = 6

| Part | Token |
|---|---|
| Container | Background/Floated · 위 모서리 `radius-xl` 20 · Shadow/Large · 위 `spacing-12` / 아래 `spacing-16` |
| Handle | `handle-width` 40 × `handle-height` 4 · Grey 300 |
| Header | padding 좌 `spacing-24` · 우 `spacing-20` · 상하 `spacing-16` |
| Title / Description | Body xl/Bold / Body md/Regular · Text/Tertiary |
| Close | `icon-lg` 24 · Icon/Primary |
| Content | 좌우 `spacing-20` · Slot |
| Footer | Action Button XL · 좌우 `page-margin` 20 · 위 `spacing-16` |
| Dim | Background/Dim |

**Properties**: Handle (Boolean) · Title · Description (Boolean) · Description Text · Close Button (Boolean) · Content Swap (Instance swap; List · Wheel Picker · Date Picker 등) · Slot · Header Align · Footer

**Usage**
- 높이는 내용에 맞추되 화면의 90%를 넘지 않게. 넘치면 콘텐츠 안에서 스크롤.
- 선택 즉시 닫히는 목록은 Footer 없이, 여러 값을 고르는 필터는 Footer에서 확정.
- 행동 목록만 보여줄 땐 Menu Sheet.

### 6.2 Menu

버튼을 누르면 근처에 뜨는 행동 목록. 웹·태블릿의 더보기 메뉴용이며 모바일에서는 같은 내용을 Menu Sheet로 띄운다. · Web · Tablet · v1.0

**구성**: Menu (컨테이너, Item 인스턴스 추가·삭제) · Menu / Item (Tone × State, 7 variants)

| Part | Token |
|---|---|
| Menu | `menu-width` 240 · Background/Floated · padding `spacing-8` · gap `spacing-2` · `radius-lg` 16 · Border/Default · Shadow/Medium |
| Item | `row-height` 48 · padding `spacing-12` · gap `spacing-8` · `radius-sm` 8 |
| Label | Body md/Regular (Selected: Semibold, Text/Brand) |
| Critical | Text/Danger · Icon/Danger |
| Pressed | Fill/Pressed |
| Divider | Border/Default · `border-thin` |

**Item 속성**: Prefix Icon (Boolean, true) · Label · Tone (Neutral · Critical) · State (Enabled · Pressed · Selected · Disabled — Critical은 Selected 없음)

**Usage**
- 항목은 2~7개. 더 많으면 묶음을 나누거나 화면을 따로 만든다.
- 삭제·신고 같은 위험한 행동은 맨 아래 Divider 뒤에 Critical.
- 모바일에서는 Menu Sheet.

---

## 7. Navigation

### 7.1 Tabs

같은 화면 안에서 콘텐츠 묶음을 바꿔 볼 때 쓴다. 탭이 2~4개면 Fixed, 5개 이상이면 Fluid(가로 스크롤). 알약 모양 필터는 Chip. · Mobile · Web · **v2.0**

**구성**: Tab (Width × Size × Selected = 8) · Tabs (Alignment × Size = 4)

| Part | Fixed | Fluid |
|---|---|---|
| Height | L `tab-height-l` 51 · S `tab-height-s` 38 | 같음 |
| Padding X | 바깥 `spacing-20` · 탭 `spacing-8` | 바깥 왼쪽 `tab-padding-fluid` 14, 오른쪽 0 · 탭 `spacing-12` |
| Label | L Body lg · S Body md (선택 Bold · 안 됨 Semibold) | 같음 |
| Selected | Text/Primary + 밑줄 `border-thick` 2 (Grey 800, 글자 폭, 끝 둥글게) | 같음 |
| Unselected | Text/Tertiary | 같음 |
| Container | Background/Default + 아래 Border/Default 1px · 탭 너비 균등 | 같음 · 글자 너비만큼 + 끝 Scroll Fog 40 |

**Properties · Tab**: Label · Width (Fixed · Fluid) · Size (L · S) · Selected (False · True)
**Properties · Tabs**: Alignment (Fixed · Fluid) · Size (L · S) · Show Right Fog (Boolean, true) · Show Left Fog (Boolean, false)

**Usage**
- 2~4개면 Fixed(균등), 5개 이상이면 Fluid + 가로 스크롤 + Scroll Fog.
- 탭 전환은 같은 화면 안의 콘텐츠만 바꾼다. 알약 필터·카테고리는 Chip.
- 보기 방식만 바꾸는 2~3개 선택은 Segmented Control이 더 가볍다.

---

## 8. Owner App · iPad

사장님 앱(iPad) 전용 컴포넌트. 모두 **iPad 전용 · v1.0**이고 UIUX 사장님 앱 v3에서 옮겨 왔다.

### 8.1 Top Bar

사장님 앱 모든 화면 맨 위 바. 매장 이름 · 영업 상태 · 탭 5개 · 소리 · 시각을 한 줄(높이 64)에 담는다.

**구성**: Top Bar (Tab 5 variants) · `.primitive / Top Bar / Store Status` (Status 3 variants — Top Bar 안에서만 쓰는 보조 부품)

| Part | 값 |
|---|---|
| Top Bar | 높이 64 · Fill/Neutral |
| 영업 상태 버튼 | 높이 36 · 누르면 DS Menu가 바로 아래로 열림 |
| 탭 | 5개, 가운데 배치 · 선택은 글자색만(고른 탭만 흰 글자, 밑줄·알약 없음) |

**Properties**

| Property | Type | Default / Values | 설명 |
|---|---|---|---|
| Tab | Variant | 주문 · 오늘 내역 · 메뉴 관리 · 매출 · 설정 | 선택된 탭 |
| Store | Text | 범석관 카페 | 매장 이름 |
| Time | Text | 13:05 | 현재 시각 |
| Show Count | Boolean | true | 접수 대기 건수 (DS Count Badge). 0이면 끈다 |
| Store Status › Status | Variant | 영업 중 · 잠시 중지 · 마감 | 영업 상태 |

**Usage**
- 모든 화면 맨 위에 하나. 탭을 누르면 그 화면으로 바로 간다 (매출·메뉴 수정은 2차 비밀번호 먼저).
- 영업 상태 버튼을 누르면 DS Menu가 바로 아래로 열린다.
- 소리가 꺼지면 스피커 아이콘이 `volume-off`로 바뀐다.

### 8.2 Column Head

주문 보드 칸반 레인의 제목. 제목(Body xl/Bold 20) + 레인 전체 건수.

**Variants**: Tone(Brand · Neutral) = 2 — Brand: 손이 가야 하는 접수 대기 1건 이상 · Neutral: 그 외 (0이면 회색)

**Properties**: Title (접수 대기) · Count (2) · Show Count (Boolean, true — 불러오는 중이면 건수 숨김) · Tone

**Usage**
- 레인마다 맨 위에 하나. 레인을 스크롤해도 제목은 고정.
- 숫자는 레인 전체 건수다 (화면에 안 보이는 카드 포함).

### 8.3 Order Card

주문 한 건을 보여주는 카드 (레인 안 폭 340). 번호 · 수령 방법 · 이름 · 상태 + 메뉴 줄 + 버튼.

**구성**: Order Card (Stage × State, 5 variants) · `.primitive / Order Card / Item` (메뉴 ×수량 Body lg/Semibold + 옵션 `ㄴ ` Body md/Regular)

**타이포그래피**

| 위치 | 스타일 |
|---|---|
| 번호 | Display md/Bold 36 |
| 수령 방법 | Body lg/Bold |
| 이름 | Body sm/Regular |
| 오른쪽 상태 | Body md/Medium |
| 버튼 | Action Button L(48) 그대로, 글자만 Body lg/Semibold 18 |

**Properties**

| Property | Type | Default / Values | 설명 |
|---|---|---|---|
| Stage | Variant | 접수 대기 · 제조중 · 픽업 대기 | 접수 대기(거절·수락) / 제조중(조리 완료) / 픽업 대기(정리하기·픽업 완료) |
| State | Variant | Default · Alert | Alert = 시간이 넘음: 오른쪽 글자만 Text/Danger |
| Number · Pickup · Name | Text | 31 · 테이크아웃 · 가을 | 번호 · 수령 방법 · 이름 |
| Show Item 2 ~ 5 | Boolean | false | 메뉴 줄 예시 (5줄까지) |
| Show Actions | Boolean | true | 버튼 줄 |

예시 조합: 접수 대기 · 제조중 · 픽업 대기, 접수 대기 · Alert (자동 취소 2분 전), 픽업 대기 · Alert (픽업 예정 지남).

**Usage**
- 수락하면 제조중 맨 아래로, 조리 완료·픽업 완료는 15초 되돌리기.
- 고객 취소·자동 취소는 오른쪽 상태 글자 + 메뉴 취소선, 버튼 숨김.
- 정리 가능 시간 전에는 남은 시간 안내 없이 [픽업 완료]만 보인다.
- 메뉴 줄은 개수와 상관없이 카드 안에 계속 쌓는다 ("외 N개"로 줄이지 않음. 컴포넌트에는 5줄까지 예시).
- 카드는 테두리로 강조하지 않는다 (11/22 Highlight 삭제). 수락한 주문은 카드에서 취소할 수 없다 (11/22 ⋯ · 1.4.4 삭제).
- 상태는 색만이 아니라 글자로도 알린다.

### 8.4 PIN Pad

2차 비밀번호 숫자 4자리를 넣는 키패드. 점 4개 + 숫자 키 + 지우기.

**Variants**: State(Default · Error · Locked) = 3 — Error: 점이 좌우로 흔들리고 비워짐 · Locked: 키가 꺼짐 (30초)

**Usage**
- 가운데 Dialog(폭 376 · `radius-2xl` 24) 안에 제목과 함께 넣는다.
- 오류·잠금 문구는 PIN Pad 안이 아니라 창 제목 바로 아래 빨간 글자 (Body md/Medium · Text/Danger).
- 키 = DS Action Button Ghost XL. 4자리를 다 누르면 바로 확인한다.
- 처음 정할 때는 "2차 비밀번호를 정해 주세요" → "한 번 더 입력해 주세요" 두 단계.

### 8.5 Table

표 머리 칸과 칸. 오늘 처리 내역처럼 줄이 많은 목록에 쓴다 (관리자 웹에도 사용).

**구성**: Table / Header Cell (Align 2 variants) · Table / Cell (Type × State × Align, 10 variants)

| Part | 값 |
|---|---|
| Header Cell | 높이 44 · Background/Upper · 아래 테두리 Border |
| Cell | 높이 64 · 아래 테두리 Border |
| Selected | 오른쪽에 상세가 열린 줄 (Fill/Brand Weak). 한 줄의 칸을 모두 Selected로 |
| 칸 폭 | 표마다 정함 (고정 폭 또는 채우기) |

**Properties**

| Component | Property | Values / Default |
|---|---|---|
| Header Cell | Label (머리글) · Align | Left · Right (숫자·금액) |
| Cell | Type | Text (한 줄, 넘치면 …) · Two Lines (굵은 글 + 보조 글) · Badge (DS Badge 노출, 톤·글자 변경) |
| Cell | State | Default · Selected |
| Cell | Align | Left · Right |
| Cell | Text · Sub Text | 텍스트 · 보조 글 |

**Usage**
- 숫자·금액 열은 오른쪽 정렬.
- 줄 = 칸을 가로로 이은 자동 배치 프레임, 표 = 머리 줄 + 줄.
- 줄이 많으면 표 영역만 세로 스크롤, 머리 칸은 고정.

---

## 9. 부록: 원본 문서의 불일치

Figma 변수 값과 문서 텍스트를 대조하면서 발견한 어긋남이다. 이 md에서는 둘 다 원문 그대로 적었으니, 구현 전에 어느 쪽이 기준인지 확인이 필요하다.

| # | 항목 | 변수 / 토큰 값 | 문서 텍스트 |
|---|---|---|---|
| 1 | `page-margin` | `spacing-24` (설명: "TDS와 같이 24") | Spacing 문서 Layout, List · Divider · Skeleton 스펙은 `page-margin` **20**으로 기재 |
| 2 | `radius-md` | 12 | Image Frame 스펙: "Medium `radius-md` 14" (14는 `radius-14`) |
| 3 | Switch M 트랙 | `switch-width-m` 50 × `switch-height-m` 30 (TDS) | Switch 스펙: `switch-width-m` 40 × `icon-lg` 24 |
| 4 | `tab-padding-fluid` | 값 8 | 설명과 Tabs 스펙은 14 |
| 5 | Bottom Sheet 모서리 | `sheet-radius` 28 (TDS) | Bottom Sheet 스펙·Spacing 문서는 `radius-xl` 20 |
| 6 | Badge 크기 | `badge-height-m` 24 · `badge-height-l` 28 | Badge Size guide는 "L 24 (Mobile) / M 22 (Web)" |
| 7 | Dark `Border/Default` | `Background/Lower`(`#101013`)를 참조 | Light는 Grey Opacity 200 — 모드 간 참조 방식이 다름 |
| 8 | 설명 누락 | `Text/On Fill Brand`, `Shadow/Tiny · Weak · Medium`은 변수 description이 비어 있음 | — |
| 9 | Effects 투명도 | 효과 스타일: Shadow Small `#001B37` 10% · Medium 10% · Large `#001D3A` 18% · Focus Ring `#298DFF` 47% | Effects 문서: 6% · 10% · 14% · Focus "Blue 35%" |
| 10 | PIN Pad 설명 | — | 컴포넌트 설명 끝에 "잠금 상태에서도 눌려요." 문장이 여러 번 반복돼 있고 잘려 있다. 문서 본문에는 Locked = 키가 꺼짐(30초)이라 적혀 있어 서로 모순돼 보인다 |

**기타**: `z_System Components` 페이지에는 iOS Status bar(iPhone X 이후, Theme Light / Dark) 컴포넌트만 있고 문서 텍스트는 없다. Thumbnail 페이지는 표지다.
