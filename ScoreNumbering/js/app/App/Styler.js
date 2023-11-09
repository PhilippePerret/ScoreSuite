"use strict";

/**
* Pour gérer le style du numéro
*/

class Styler {

  static prepare(){
    listen(this.menuFontFamily, "change",  this.onChangeFontFamily.bind(this))
    listen(this.menuFontSize,   "change",  this.onChangeFontSize.bind(this))
    listen(this.menuFontColor,  "change",   this.onChangeFontColor.bind(this))

  }

  static onChangeFontFamily(ev){
    stopEvent(ev)
    Score.current.setEachNumero("fontFamily", this.getFontFamily())
  }
  static onChangeFontSize(ev){
    stopEvent(ev)
    Score.current.setEachNumero("fontSize", this.getFontSize() + "px")
  }
  static onChangeFontColor(ev){
    stopEvent(ev)
    Score.current.setEachNumero("color", this.getFontColor())
  }


  static getFontFamily(){
    return this.menuFontFamily.value
  }

  static getFontSize(){
    return this.menuFontSize.value
  }

  static getFontColor(){
    return this.menuFontColor.value
  }

  static get menuFontFamily(){return DGet("#font-family")}
  static get menuFontSize(){return DGet("#font-size")}
  static get menuFontColor(){return DGet("#font-color")}

}
