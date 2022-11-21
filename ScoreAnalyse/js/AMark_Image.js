'use strict';


class AMImage extends AMark {

constructor(analyse, data){
  super(analyse,data)
}

buildSpanContent(){
  this.img = DCreate('IMG', {class:'content', src:this.srcPath})
  return this.img
}

set content(v){
  this._content = v
  this.data.content = v
  this.img && (this.img.src = this.srcPath)
}
// Pourquoi est-on contraint de faire ça ?
get content(){
  return super.content
}

get srcPath(){
  return this.analyse.path+'/images/'+this.content
}

}// class AMIage
