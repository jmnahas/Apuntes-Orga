
## Preparación: actualizando su fork del repositorio individual
Es importante que, para esta instancia de parcial y próximas, **no creen un nuevo fork de este repositorio** si no que actualicen el mismo fork individual que estaban utilizando para el tp0.
Estas son las instrucciones para sincronizar su fork individual con el contenido del parcial.
Para la próxima instancia de parcial, o si actualizamos algún archivo durante esta instancia, deberán seguir estas mismas instrucciones para sincronizar su repositorio con el de la cátedra.

Para actualizar su fork con cambios del repositorio de la cátedra, que llamaremos "upstream", deben ejecutar los siguientes comandos desde la línea de comandos, estando ubicados dentro del clon local de su fork (de no recordar como clonar localmente su fork del repositorio individual, o tener alguna otra duda respecto a utilizar git localmente, pueden revisar las secciones correspondientes en el [enunciado del TP0](https://git.exactas.uba.ar/ayoc-doc/individual-2c2024/-/blob/master/tp0/README.md#clonando-el-repo)):

1. Agregar el repositorio de la cátedra como *upstream* remoto:
   - Si usaron https:
	```sh
	git remote add upstream https://git.exactas.uba.ar/ayoc-doc/individual-<id_cuatrimestre>.git
	```
   - Si usaron ssh:
	```sh
	git remote add upstream git@git.exactas.uba.ar:ayoc-doc/individual-<id_cuatrimestre>.git
	```
2. Traer el último estado del upstream
```sh
git fetch upstream
```
3. Moverse al branch principal (`master`) si habían cambiado de branch, ya que los cambios se sincronizarán en dicho branch únicamente
```sh
git checkout master
```
4. Combinar los cambios locales con los del *upstream*
```sh
git merge upstream/master
```

Es posible que al ejecutar el merge les aparezca CONFLICT y diga que arreglen los conflictos para poder terminar el merge.
En ese caso, deben:
1. Resolver los conflictos, ya sea con la herramienta de resolución de conflictos de VScode o a mano (se recomienda utilizar VScode).
2. Una vez resueltos los conflictos, tomar nota de cuales archivos tenían conflictos que fueron resueltos y ejecutar:
```sh
git add <archivos modificados>
git commit -m "Merge con actualizaciones cátedra"
git push origin
```