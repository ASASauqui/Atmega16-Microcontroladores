notas = c(do=261.626, re=293.665, mi=329.628, fa=349.228, sol=391.995, 
          la=440.000, si=493.883)
Ts = c()

for(i in 1:7){
  Ts = c(Ts,(1/notas[i])/2)
}

Ts


# Tiempo
fmicro = 1/1000000
ciclos = (400 * 10^-3) / fmicro
ciclos