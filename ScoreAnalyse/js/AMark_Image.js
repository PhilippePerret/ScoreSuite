'use strict';


class AMImage extends AMark {

constructor(analyse, data){
  super(analyse,data)
}

get content(){
  return this._content || (this._content = '<img src="'+this.analyse.path+'/images/'+this.data.content+'" />')
}

}// class AIMage
