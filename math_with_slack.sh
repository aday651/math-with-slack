#!/usr/bin/env bash

################################################################################
# Rendered math (MathJax) with Slack's desktop client
################################################################################
#
# Slack (https://slack.com) does not display rendered math. This script
# injects MathJax (https://www.mathjax.org) into Slack's desktop client,
# which allows you to write nice-looking inline- and display-style math
# using familiar TeX/LaTeX syntax.
#
# https://github.com/fsavje/math-with-slack
#
# MIT License, Copyright 2017 Fredrik Savje
#
################################################################################


## Constants

MWS_VERSION="v0.2.1"


## Functions

error() {
	echo "$(tput setaf 124)$(tput bold)✘ $1$(tput sgr0)"
	exit 1
}


## User input

for p in "$@"; do
	if [ "$p" = "-u" ]; then
		UNINSTALL="$p"
	else
		SLACK_DIR="$p"
	fi
done


## Platform settings

if [ "$(uname)" == "Darwin" ]; then
	# macOS
	COMMON_SLACK_LOCATIONS=(
		"/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static"
	)
else
	# Linux
	COMMON_SLACK_LOCATIONS=(
		"/usr/lib/slack/resources/app.asar.unpacked/src/static"
		"/usr/local/lib/slack/resources/app.asar.unpacked/src/static"
		"/opt/slack/resources/app.asar.unpacked/src/static"
	)
fi


## Try to find slack if not provided by user

if [ -z "$SLACK_DIR" ]; then
	for loc in "${COMMON_SLACK_LOCATIONS[@]}"; do
		if [ -e "$loc" ]; then
			SLACK_DIR="$loc"
			break
		fi
	done
	if [ -z "$SLACK_DIR" ]; then
		error "Cannot find Slack installation."
	else
		echo "Found Slack installation at: $SLACK_DIR"
	fi
fi


## Check so installation exists and is writable

if [ ! -e "$SLACK_DIR" ]; then
	error "Cannot find Slack installation at: $SLACK_DIR"
elif [ ! -e "$SLACK_DIR/ssb-interop.js" ]; then
	error "Cannot find Slack file: $SLACK_DIR/ssb-interop.js"
elif [ ! -w "$SLACK_DIR/ssb-interop.js" ]; then
	error "Cannot write to Slack file: $SLACK_DIR/ssb-interop.js"
fi


## Unistall version 0.1
## (Remove this eventually)

if [ -e "$SLACK_DIR/index.js.mwsbak" ]; then
	mv -f $SLACK_DIR/index.js.mwsbak $SLACK_DIR/index.js
fi


## Remove previous version

if [ -e "$SLACK_DIR/math-with-slack.js" ]; then
	rm $SLACK_DIR/math-with-slack.js
fi


## Restore previous injections

restore_file() {
	# Test so file been injected. If not, assume it's more recent than backup
	if grep -q "math-with-slack" $1; then
		if [ -e "$1.mwsbak" ]; then
			mv -f $1.mwsbak $1
		else
			error "Cannot restore from backup. Missing file: $1.mwsbak"
		fi
	elif [ -e "$1.mwsbak" ]; then
		rm $1.mwsbak
	fi
}

restore_file $SLACK_DIR/ssb-interop.js
restore_file $SLACK_DIR/ssb-interop-lite.js


## Are we uninstalling?

if [ -n "$UNINSTALL" ]; then
	echo "$(tput setaf 64)math-with-slack has been uninstalled. Please restart Slack client.$(tput sgr0)"
	exit 0
fi


## Write main script

cat <<EOF > $SLACK_DIR/math-with-slack.js
// math-with-slack $MWS_VERSION
// https://github.com/fsavje/math-with-slack

document.addEventListener('DOMContentLoaded', function() {
  var mathjax_config = document.createElement('script');
  mathjax_config.type = 'text/x-mathjax-config';
  mathjax_config.text = \`
    MathJax.Hub.Config({
      messageStyle: 'none',
      extensions: ['tex2jax.js'],
      jax: ['input/TeX', 'output/HTML-CSS'],
      tex2jax: {
        displayMath: [['\$\$', '\$\$']],
        element: 'msgs_div',
        ignoreClass: 'ql-editor',
        inlineMath: [['\$', '\$']],
        processEscapes: true,
        skipTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code']
      },
      TeX: {
        extensions: ['AMSmath.js', 'AMSsymbols.js', 'color.js',
          'AMScd.js', 'noErrors.js', 'noUndefined.js'],
        Macros: {
          bb: "\\\\\\\\mathbb",
          mb: "\\\\\\\\boldsymbol",
          mc: "\\\\\\\\mathcal",
          mf: "\\\\\\\\mathfrak",
          wh: "\\\\\\\\widehat",
          wt: "\\\\\\\\widetilde",
          ol: "\\\\\\\\overline",
          v: "\\\\\\\\mathbf",
          c: "\\\\\\\\mathcal",
          tp: "\^{\\\\\\\\mkern+2mu T}",
          inv: "\^{-1}",
          eps: "\\\\\\\\epsilon",
          veps: "\\\\\\\\varepsilon",
          vphi: "\\\\\\\\varphi}",
          One: "\\\\\\\\mathbf 1}",
          Zero: "\\\\\\\\mathbf 0",
          indicator: ["\\\\\\\\operatorname{\\\\\\\\mathbb 1}_{#1}",1],
          ind: ["\\\\\\\\operatorname{\\\\\\\\mathbb 1}_{#1}",1],
          rank: "\\\\\\\\operatorname{rank}",
          tr: "\\\\\\\\operatorname{tr}",
          supp: "\\\\\\\\operatorname{supp}",
          conv: "\\\\\\\\operatorname{conv}",
          Bd: "\\\\\\\\operatorname{bd}",
          Cl: "\\\\\\\\operatorname{cl}",
          Dom: "\\\\\\\\operatorname{dom}",
          Epi: "\\\\\\\\operatorname{epi}",
          Aff: "\\\\\\\\operatorname{aff}",
          Cone: "\\\\\\\\operatorname{cone}",
          Int: "\\\\\\\\operatorname{int}",
          Relint: "\\\\\\\\operatorname{relint}",
          Span: "\\\\\\\\operatorname{span}",
          Diam: "\\\\\\\\operatorname{diam}",
          dist: "\\\\\\\\operatorname{dist}",
          vect: "\\\\\\\\operatorname{vec}",
          vol: "\\\\\\\\operatorname{vol}",
          E: "\\\\\\\\operatorname{\\\\\\\\mathbb E}",
          P: "\\\\\\\\operatorname{\\\\\\\\mathbb P}",
          var: "\\\\\\\\operatorname{var}",
          cov: "\\\\\\\\operatorname{cov}",
          diag: "\\\\\\\\operatorname{diag}",
          sign: "\\\\\\\\operatorname{sign}",
          grad: "\\\\\\\\operatorname{grad}",
          Hess: "\\\\\\\\operatorname{Hess}",
          mini: "\\\\\\\\operatorname{minimize}",
          maxi: "\\\\\\\\operatorname{maximize}",
          st: "\\\\\\\\operatorname{subject\\\\\\\\; to}",
          im: "\\\\\\\\mathrm i",
          iu: "\\\\\\\\hat{\\\\\\\\mathfrak i}",
          indep:"\\\\\\\\perp\\\\\\\\!\\\\\\\\!\\\\\\\\!\\\\\\\\perp",
          norm: ["\\\\\\\\left\\\\\\\\lVert #1 \\\\\\\\right\\\\\\\\rVert",1],
          abs: ["\\\\\\\\left\\\\\\\\lvert #1 \\\\\\\\right\\\\\\\\rvert", 1],
          innerprod: ["\\\\\\\\left\\\\\\\\langle #1, #2\\\\\\\\right\\\\\\\\rangle", 2],
          ip: ["\\\\\\\\left\\\\\\\\langle #1, #2\\\\\\\\right\\\\\\\\rangle", 2],
          prob: ["\\\\\\\\operatorname{\\\\\\\\mathbb{P}}\\\\\\\\left[ #1 \\\\\\\\right]",1],
          expect: ["\\\\\\\\operatorname{\\\\\\\\mathbb{E}}\\\\\\\\left[ #1 \\\\\\\\right]",1],
          set: ["\\\\\\\\left\\\\\\\\{ #1 \\\\\\\\right\\\\\\\\}", 1],
          condset: ["\\\\\\\\left\\\\\\\\{ #1 \\\\\\\\;\\\\\\\\middle|\\\\\\\\; #2 \\\\\\\\right\\\\\\\\}", 2],
          ceil: ["\\\\\\\\left\\\\\\\\lceil #1 \\\\\\\\right\\\\\\\\rceil",1],
          floor: ["\\\\\\\\left\\\\\\\\lfloor #1 \\\\\\\\right\\\\\\\\rfloor",1]
        }
      }
    });
  \`;
  var mathjax_script = document.createElement('script');
  mathjax_script.type = 'text/javascript';
  mathjax_script.src = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js';
  document.head.appendChild(mathjax_config);
  document.head.appendChild(mathjax_script);

  var target = document.querySelector('#msgs_div');
  var options = { attributes: false, childList: true, characterData: true, subtree: true };
  var observer = new MutationObserver(function (r, o) { MathJax.Hub.Queue(['Typeset', MathJax.Hub]); });
  observer.observe(target, options);
});
EOF

# leftover macros:
#Pr: "{\\let\\Pr\\relax \\operatorname{\\mathbb P}}",
#tp: "{\^{\\mkern+2mu T}}",
#inv: "{\^{-1}}",

## Inject code loader

inject_loader() {
	# Check so not already injected
	if grep -q "math-with-slack" $1; then
		error "File already injected: $1"
	fi

	# Make backup
	if [ ! -e "$1.mwsbak" ]; then
		cp $1 $1.mwsbak
	else
		error "Backup already exists: $1.mwsbak"
	fi

	# Inject loader code
	echo "" >> $1
	echo "// ** math-with-slack $MWS_VERSION ** https://github.com/fsavje/math-with-slack" >> $1
	echo "var mwsp = path.join(__dirname, 'math-with-slack.js').replace('app.asar', 'app.asar.unpacked');" >> $1
	echo "require('fs').readFile(mwsp, 'utf8', (e, r) => { if (e) { throw e; } else { eval(r); } });" >> $1
}

inject_loader $SLACK_DIR/ssb-interop.js
inject_loader $SLACK_DIR/ssb-interop-lite.js


## We're done

echo "$(tput setaf 64)math-with-slack has been installed. Please restart Slack client.$(tput sgr0)"

