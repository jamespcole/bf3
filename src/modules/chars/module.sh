
# NOTES: The following can be useful when trying to get the character code
# echo -n '▻' |xxd -p -u
# Find a good list of useful chars here:
# http://www.fileformat.info/info/unicode/category/So/list.htm
# To use import this module and reference like this:
# echo "@get(chars.figs['INFO_ROUND'])"

@namespace

@create{}(@this.figs)
@set(@this.figs['SKLL_N_CB'])="\xE2\x98\xA0" # ☠
@set(@this.figs['SKULL'])="\xF0\x9F\x92\x80" # 💀
@set(@this.figs['INFO'])="\xE2\x84\xB9" # ℹ
@set(@this.figs['INFO_ROUND'])="\xF0\x9F\x9B\x88" # 🛈
@set(@this.figs['WARN'])="\xE2\x9A\xA0" # ⚠
@set(@this.figs['TICK'])="\xF0\x9F\x97\xB8" # 🗸
@set(@this.figs['FISHEYE'])="\xE2\x97\x89" # ◉
@set(@this.figs['CIRCLE'])="\xE2\x97\x8F" # ●
@set(@this.figs['SMALL_CIRCLE'])="\xE2\x9A\xAC" # ⚬
@set(@this.figs['POINT_RIGHT'])="\xF0\x9F\x91\x89" # 👉
@set(@this.figs['CLOCK'])="\xF0\x9F\x95\x93" # 🕓
@set(@this.figs['STAR'])="\xE2\x98\x85" # ★
@set(@this.figs['TRI_SOLID_RIGHT'])="\xE2\x96\xB6" # ▶
@set(@this.figs['TRI_THIN_RIGHT'])="\xE2\x96\xBB" # ▻

@create{}(@this.box)
@set(@this.box['DBL_SE'])="\xE2\x95\x94" # ╔
@set(@this.box['DBL_SW'])="\xE2\x95\x97"
@set(@this.box['DBL_NW'])="\xE2\x95\x9D" # ╝
@set(@this.box['DBL_NE'])="\xE2\x95\x9A" # ╚
@set(@this.box['DBL_NSE'])="\xE2\x95\xA0" # ╠
@set(@this.box['DBL_NSW'])="\xE2\x95\xA3" # ╣
@set(@this.box['DBL_EW'])="\xE2\x95\x90" # ═
@set(@this.box['DBL_SEW'])="\xE2\x95\xA6" # ╦
@set(@this.box['DBL_NS'])="\xE2\x95\x91" # ║
@set(@this.box['DBL_NEW'])="\xE2\x95\xA9" # ╩

@set(@this.box['DBL_W_THIN_S'])="\xE2\x95\x95" # ╕
@set(@this.box['DBL_E_THIN_S'])="\xE2\x95\x92" # ╒
@set(@this.box['DBL_EW_THIN_S'])="\xE2\x95\xA4" # ╤
@set(@this.box['DBL_EW_THIN_N'])="\xE2\x95\xA7" # ╧
@set(@this.box['DBL_EW_THIN_NS'])="\xE2\x95\xAA" # ╪

@set(@this.box['ANGLE_BS'])="\xE2\x95\xB2" # ╲
@set(@this.box['ANGLE_FS'])="\xE2\x95\xB1" # ╱

@set(@this.box['THIN_SE'])="\xE2\x94\x8C" # ┌
@set(@this.box['THIN_SW'])="\xE2\x94\x90" # ┐
@set(@this.box['THIN_NS'])="\xE2\x94\x82" # │
@set(@this.box['THIN_EW'])="\xE2\x94\x80" # ─
@set(@this.box['THIN_NE'])="\xE2\x94\x94" # └
@set(@this.box['THIN_NW'])="\xE2\x94\x98" # ┘
@set(@this.box['THIN_NSE'])="\xE2\x94\x9C" # ├ echo -n '┬' |xxd -p -u
@set(@this.box['THIN_NSW'])="\xE2\x94\xA4" # ┤
@set(@this.box['THIN_SEW'])="\xE2\x94\xAC" # ┬
