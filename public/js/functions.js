function verificar(){
  if (document.getElementById('barcos').value > 0) {
    alert("Aun te quedan "+document.getElementById('barcos').value+" barcos por colocar")
    return false
  }
}

function assignPosition(position){ 
  barcos = document.getElementById('barcos').value
  if  (barcos > 0) {
    //document.getElementById('barco'+barcos).value = 'position'
    document.getElementById(position).style.backgroundColor = 'red'
    document.getElementById(position).value = 'Ship'
    document.getElementById(position).disabled = 'disabled'
    document.getElementById('barco'+barcos).value= position
    document.getElementById('barcos').value -= 1
  }else{ 
    alert("All ships assigned")
  }  
} 



/*function assignPosition(a){
  alert("funciona!"+a)
}*/