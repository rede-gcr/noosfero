function prepareMenu(id, options) {

    window.menuCloseTimeout = options.timeout || 333;

    if ( document.all ) {
        // add a class for work arround msie's css bugs
        $(id).className += " msie";
    }
    
    var zIndex = 10;
    
    $$("#" + id + " ul ul").each( function( ul ) { // para cada UL de sub-menu faça:
        // Pega o link que abre este sub-menu:
        var linkText = ul.parentNode.firstChild;
        // Retira espaço em branco sobrando nas bordas deste:
        linkText.nodeValue = linkText.nodeValue.replace( /^\s*|\s*$/g, "" );

        // Create a link to open this sub-menu:
        var link = document.createElement("a");
        link.href = "#";
        link.className = "linkSubMenu";
        linkText.parentNode.insertBefore( link, linkText );
        link.parentNode.style.zIndex = zIndex++;
        link.subMenu = ul;
        var span = document.createElement("span");
        span.appendChild( linkText );
        link.appendChild( span );
        ul.linkControle = link;
        link.openSubMenu =
            function ( isMouseClick ) {
                if( this.subMenu.style.display == "block" ) {
                    if( isMouseClick ) {
                        this.subMenu.style.display = "none";
                    } else {
                        clearTimeout(this.timeOutClose);
                        clearTimeout(this.subMenu.timeOutClose);
                        return false;
                    }
                } else {
                    if ( window.openedMenu ) window.openedMenu.closeSubMenu();
                    window.openedMenu = this.subMenu;
                    this.className += " menu-opened"
                    this.subMenu.style.display = "block";
                    clearTimeout(this.timeOutClose);
                    clearTimeout(this.subMenu.timeOutClose);
                }
            }
        link.closeSubMenu =
            function(){
              this.subMenu.style.display = "none";
              link.className = link.className.replace( / menu-opened/g, "" );
            }

        //link.onclick = function(){ this.openSubMenu(true); return false }Is not working

        // onmouseout e onmouseover manipulam o menu para pessoas normais
        // onblur e onfocus manipulam o menu para pessoas que precisam navegar com tab

        link.onmouseover = link.onfocus =
            function () {
                this.openSubMenu(false);
            };
        link.onmouseout = link.onblur =
            function () {
                this.timeOutClose = setTimeout( this.closeSubMenu.bind(this), window.menuCloseTimeout );
            };

        //ul.closeSubMenu = function(){ this.style.display = "none" }
        ul.closeSubMenu = function(){ this.linkControle.closeSubMenu() }

        ul.onmouseover = ul.onfocus =
            function () {
                this.blurCalledByIEWorkArroundBug = false;
                clearTimeout(this.timeOutClose);
                clearTimeout(this.linkControle.timeOutClose);
            };
        ul.onmouseout = ul.onblur =
            function () {
                if ( this.blurCalledByIEWorkArroundBug ) { return false }
                this.blurCalledByIEWorkArroundBug = true;
                this.timeOutClose = setTimeout( this.closeSubMenu.bind(this), window.menuCloseTimeout );
            };
    });


    // **** begin of workaround for Microsoft Internet Explorer ****
    // MS IE sucks, BTW.
    if ( document.all ) {
        function forceUlFocusFromLink ( a ) {
            var stop = false;
            a.ancestors().each( function(el) {
                if ( el.id == "menu" ) { stop = true }
                if ( ! stop && el.onfocus ) { el.onfocus() }
            } );
        }
        function forceUlBlurFromLink ( a ) {
            var stop = false;
            a.ancestors().each( function(el) {
                if ( el.id == "menu" ) { stop = true }
                if ( ! stop && el.onblur ) { el.onblur() }
            } );
        }
        $$("#" + id + " ul ul a").each( function( a ) {
            // os links do sub menu forçarão o foco do ul
            if ( a.className == "linkSubMenu" ) {
                a.onfocus = function() {
                    forceUlFocusFromLink(this);
                    this.openSubMenu(false);
                };
                a.onblur = function() {
                    forceUlBlurFromLink(this);
                    this.timeOutClose = setTimeout( this.closeSubMenu.bind(this), window.menuCloseTimeout );
                };
            } else {
                a.onfocus = function() { forceUlFocusFromLink(this) };
                a.onblur  = function() { forceUlBlurFromLink(this)  };
            }
        });
    } // ** end of workaround for Microsoft Internet Explorer.

}
