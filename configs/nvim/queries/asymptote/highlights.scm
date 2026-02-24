;extends

((type_identifier) @keyword.import
	(#in_asy?)
	(#any-of? @keyword.import "access" "from" "import" ))


((identifier) @constant.builtin
	(#in_asy?)
	(#any-of? @constant.builtin "currentpicture" "currentpen" "defaultpen"
	"inch" "inches" "cm" "mm" "bp" "pt" "up" "down" "right" "left"
	"pi" "twopi"
	"undefined" "sqrtEpsilon" "Align" "mantissaBits"
	"identity" "zeroTransform" "invert"
	"stdin" "stdout"
	"unitsquare" "unitcircle" "circleprecision"
	"solid" "dotted" "Dotted" "dashed" "dashdotted"
	"longdashed" "longdashdotted"
	"squarecap" "roundcap" "extendcap"
	"miterjoin" "roundjoin" "beveljoin"
	"zerowinding" "evenodd" "basealign" "nobasealign"

	"black" "white" "gray" "red" "green" "blue" "Cyan" "Magenta"
	"Yellow" "Black" "cyan" "magenta" "yellow" "palered"
	"palegreen" "paleblue" "palecyan" "palemagenta"
	"paleyellow" "palegray" "lightred" "lightgreen"
	"lightblue" "lightcyan" "lightmagenta" "lightyellow"
	"lightgray" "mediumred" "mediumgreen" "mediumblue"
	"mediumcyan" "mediummagenta" "mediumyellow"
	"mediumgray" "heavyred" "heavygreen" "heavyblue"
	"heavycyan" "heavymagenta" "lightolive" "heavygray"
	"deepred" "deepgreen" "deepblue" "deepcyan"
	"deepmagenta" "deepyellow" "deepgray" "darkred"
	"darkgreen" "darkblue" "darkcyan" "darkmagenta"
	"darkolive" "darkgray" "orange" "fuchsia" "chartreuse"
	"springgreen" "purple" "royalblue" "salmon" "brown"
	"olive" "darkbrown" "pink" "palegrey" "lightgrey"
	"mediumgrey" "grey" "heavygrey" "deepgrey" "darkgrey"

	"thinp" "thickp"
	))
