# Trazabilidad de requisitos

## Requisitos

### Barista Bot (transicion de estados)

| Requisito | Descripcion |
|---|---|
| REQ-BB-01 | El sistema permite consultar el estado actual y la definicion de la maquina de estados. |
| REQ-BB-02 | Cada evento valido en su estado correspondiente produce la transicion y la accion definidas. |
| REQ-BB-03 | Un evento que no es valido en el estado actual no cambia el estado del robot. |
| REQ-BB-04 | Un evento desconocido es rechazado con codigo 400. |
| REQ-BB-05 | El robot puede reiniciarse al estado inicial En Espera. |

Estados: En Espera, Moliendo, Calentando Agua, Sirviendo, Error de Insumos.
Eventos: Iniciar Pedido, Terminar Molienda, Alcanzar Temperatura, Terminar Llenado, Sin Ingredientes, Recargar y Reiniciar.
La matriz tiene 30 combinaciones estado-evento: 8 validas (issues 2 a 9) y 22 invalidas (issue 10).

### Controlador de climatizacion (tabla de decision)

| Requisito | Descripcion |
|---|---|
| REQ-CL-01 | El sistema expone las condiciones de la tabla de decision y el numero de reglas. |
| REQ-CL-02 | Regla 1: con puertas o ventanas abiertas se apaga el sistema y se emite alerta sonora. |
| REQ-CL-03 | Regla 2: temperatura alta, presencia y puertas cerradas enciende la refrigeracion. |
| REQ-CL-04 | Regla 3: temperatura alta, sin presencia y puertas cerradas mantiene bajo consumo. |
| REQ-CL-05 | Regla 4: temperatura normal y puertas cerradas mantiene el sistema apagado. |
| REQ-CL-06 | Una evaluacion con un numero incorrecto de valores es rechazada con codigo 400. |
| REQ-CL-07 | Las evaluaciones se registran en el historial y este puede reiniciarse. |

Las 8 combinaciones de las 3 condiciones quedan cubiertas: 4 en la Regla 1, 1 en la Regla 2, 1 en la Regla 3 y 2 en la Regla 4.

## Matriz requisito - escenario - issue

| Issue | Requisito | Feature | Escenario | Etiquetas de ejecucion |
|---|---|---|---|---|
| 1 | REQ-BB-01 | barista.feature | Consultar el estado inicial del robot | @smoketest @Issue-1 |
| 2 | REQ-BB-02 | barista.feature | Iniciar pedido desde En Espera pasa a Moliendo | @smoketest @Issue-2 |
| 3 | REQ-BB-02 | barista.feature | Terminar molienda desde Moliendo pasa a Calentando Agua | @regression @Issue-3 |
| 4 | REQ-BB-02 | barista.feature | Falta de ingredientes durante la molienda pasa a Error de Insumos | @regression @Issue-4 |
| 5 | REQ-BB-02 | barista.feature | Alcanzar temperatura desde Calentando Agua pasa a Sirviendo | @regression @Issue-5 |
| 6 | REQ-BB-02 | barista.feature | Falta de ingredientes mientras se calienta el agua pasa a Error de Insumos | @regression @Issue-6 |
| 7 | REQ-BB-02 | barista.feature | Terminar llenado desde Sirviendo regresa a En Espera | @regression @Issue-7 |
| 8 | REQ-BB-02 | barista.feature | Falta de ingredientes mientras se sirve pasa a Error de Insumos | @regression @Issue-8 |
| 9 | REQ-BB-02 | barista.feature | Recargar y reiniciar desde Error de Insumos regresa a En Espera | @regression @Issue-9 |
| 10 | REQ-BB-03 | barista.feature | Evento invalido en cada estado no cambia el estado (22 ejemplos) | @regression @Issue-10 |
| 11 | REQ-BB-04 | barista.feature | Rechazar un evento que no existe en la maquina | @regression @Issue-11 |
| 12 | REQ-BB-05 | barista.feature | Reiniciar el robot desde un estado intermedio lo devuelve a En Espera | @smoketest @Issue-12 |
| 13 | REQ-CL-01 | climatizacion.feature | Consultar la definicion con las condiciones y el total de reglas | @smoketest @Issue-13 |
| 14 | REQ-CL-02 | climatizacion.feature | Regla 1, puertas abiertas apaga el sistema (4 ejemplos) | @regression @Issue-14 |
| 15 | REQ-CL-03 | climatizacion.feature | Regla 2, enciende la refrigeracion | @smoketest @Issue-15 |
| 16 | REQ-CL-04 | climatizacion.feature | Regla 3, mantiene bajo consumo | @regression @Issue-16 |
| 17 | REQ-CL-05 | climatizacion.feature | Regla 4, mantiene el sistema apagado (2 ejemplos) | @regression @Issue-17 |
| 18 | REQ-CL-06 | climatizacion.feature | Rechazar una evaluacion con menos valores de los esperados | @regression @Issue-18 |
| 19 | REQ-CL-07 | climatizacion.feature | Las evaluaciones quedan en el historial y se pueden reiniciar | @regression @Issue-19 |

## Como correr un escenario desde su issue

Desde la pestana Actions, workflow "CI / CD Pipeline", Run workflow, y en el campo de etiqueta escribir `@Issue-N`.
El pipeline ejecuta solo ese escenario, comenta el resultado en el issue y actualiza la etiqueta `status:passed` o `status:failed`.
