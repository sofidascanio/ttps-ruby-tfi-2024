# Trabajo Final Integrador - Taller de Tecnologias de Produccion de Software (Ruby)

<h1 align="center"> AVIVAS </h1>

Aplicación de gestión de inventario de indumentaria para la cadena de ropa deportiva 'AVIVAS'. La aplicación permite al personal de la cadena administrar el stock de productos, realizar ventas y tener una página pública que permita mostrar los productos que la tienda tiene en stock.


## Comandos 

Instalar las dependencias

```
bundle install
```

Correr las Migraciones

```
rails db:migrate
```

Reiniciar la Base de Datos (y ejecutar el seeds)

```
rails db:reset
```

Correr la aplicación

```
rails server
```

## Usuarios de Prueba

Todos los usuarios tienen ```contraseña``` = 123456

**Usuarios con rol *Administrador***:
+ ```email```: sofia@gmail.com
+ ```email```: jorge@gmail.com

**Usuarios con rol *Gerente***:
+ ```email```: juan@gmail.com
+ ```email```: lucia@gmail.com

**Usuarios con rol *Empleado***:
+ ```email```: pedro@gmail.com
+ ```email```: martina@gmail.com

## Gemas

Las gemas utilizadas en este proyecto son:

+ ```rails-i18n```: para manejar internalización (traducción).
+ ```color```: para representar los colores de los productos.
+ ```devise```: para manejar la autenticación de los usuarios.
+ ```faker```: para generar datos de prueba en el seeds.
+ ```ransack```: para realizar busquedas sobre los productos en el storefront.
+ ```kaminari```: para la paginación.
+ ```cancancan```: para manejar autorización de los usuarios.
+ ```rubocop```: para formatear el codigo. (Se ejecuta con ``` rubocop -A ```).

## Modelo 

### Productos

Se permite a los usuarios del sistema gestionar los productos.

De cada producto se guarda:
+ ```name```: Nombre (obligatorio).
+ ```description```: Descripción (opcional).
+ ```price```: Precio unitario (obligatorio).
+ ```stock```: Stock disponible (obligatorio).
+ ```images```: Imagenes.
+ ```size```: Talle (opcional).
+ ```color```: Color.
+ ```created_at```: Fecha de ingreso al inventario.
+ ```updated_at```: Fecha de ultima modificación.
+ ```deleted_at```: Fecha de baja (solo si fue eliminado).
+ ```categories```: Categorias (Relacion muchos a muchos con ```Category```).
 
Los productos se borran "logicamente", no se borran de la base de datos, al "eliminar" un producto se le agrega una ```Fecha de Baja``` y su stock pasa a ```0```.
Se pueden "restaurar" los productos para poder modificarlos y agregarle stock.

Las imagenes de los productos se manejan con ```Active Storage```. Se guardan en ```storage/product_images```.
Cada imagen tiene un registro en la tabla ```active_storage_blobs``` y la relación entre imagen-producto se guarda en ```active_storage_attachments```.

Cuando se resetea la base de datos y se ejecuta el seeds, se borran las imagenes guardadas en ```storage/product_images``` (si hay), y al crear los productos nuevamente, se relacionan de forma aleatoria con las imagenes guardadas en ```app/assets/images/products``` (tres imagenes por producto, para la presentación).

### Ventas

Se permite a los usuarios del sistema a gestionar ventas.

De cada venta se guarda:
+ ```created_at```: Fecha y hora de realización.
+ ```product_sales```: Productos vendidos, con cantidad y precio de venta (Relación intermedia ```ProductSale``` entre ```Product``` y ```Sale```).
+ ```sale_price```: Precio total de la venta.
+ ```client```: Cliente.
+ ```employee```: Empleado que realizo la venta (Relación uno a muchos con la tabla ```User```).

Al crear una venta, se descuenta el stock del producto.
+ Si se cancela la venta, se devuelve todo el stock al producto.
+ Si se modifica la venta:
    - Si se cambia la cantidad del producto, resta o agrega stock (solo resta si el producto tiene stock).
    - Si se elimina el producto, se devuelve todo el stock.

Las ventas no se borran fisicamente de la base de datos, se "cancelan" y quedan guardadas, como "Venta Cancelada".

### Usuarios

Se permite crear usuarios con diferentes roles desde la interfaz de administración (accesible solo por los usuarios autenticados)

+ ```username```: Nombre de usuario (único)
+ ```email```: Correo electronico (único)
+ ```telephone```: Telefono 
+ ```password```: Contraseña
+ ```role```: Rol
+ ```entered_at```: Fecha de ingreso a la Cadena

Hay tres roles dentro del sistema: "Administrador", "Gerente" o "Empleado"
+ Los administradores tienen acceso a todas las funcionalidades del sistema.
+ Los gerentes tienen acceso a la administración de productos, ventas y usuarios, pero no pueden crear, modificar ni borrar usuarios con el rol "Administrador"
+ Los empleados tienen acceso a la administración de productos y ventas.

Los usuarios no se borran físicamente de la base de datos, se "bloquean", mientras que este bloqueado, el usuario no puede acceder al sistema.
+ Al bloquearse, se cambia la contraseña a un valor automatico y desconocido.

Se pueden "restaurar", la contraseña cambia a "123456" (solución temporal para poder restaurar usuarios) y el usuario puede volver a acceder al sistema.

### Categorias

Para representar las categorias de los productos, cree una tabla aparte "Categoria" y la relaciono con producto.

+ ```name```: Nombre (único)
+ ```products```: Productos (Relación muchos a muchos con ```Product```)

