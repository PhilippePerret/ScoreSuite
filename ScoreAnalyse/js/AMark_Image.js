'use strict';


class AMImage extends AMark {

constructor(analyse, data){
  super(analyse,data)
}

buildSpanContent(){
  return DCreate('IMG', {
      class:'content'
    , src:  this.analyse.path+'/images/'+this.data.content
  })
}


}// class AIMage
