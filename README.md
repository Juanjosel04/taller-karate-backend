# Taller de automatizacion de pruebas backend con Karate

Suite de pruebas de API escrita con Karate Framework y Gradle para el taller de Pruebas Asistidas por IA.
Las pruebas se ejecutan contra la API publicada en Render:

`https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/`

## Ejercicios elegidos

| Bloque | Ejercicio | Tecnica | Feature |
|---|---|---|---|
| 1. Transicion de estados | 1.2 Barista Bot | Tabla de transicion de estados | `src/test/resources/features/barista.feature` |
| 2. Tablas de decision | 2.2 Controlador de climatizacion inteligente | Tabla de decision | `src/test/resources/features/climatizacion.feature` |

Son 19 escenarios definidos (44 ejecuciones contando las filas de los `Examples`). Cada escenario tiene su Issue en GitHub,
su requisito y su etiqueta de ejecucion. La matriz completa esta en [docs/trazabilidad.md](docs/trazabilidad.md).

## Estructura

```
.github/workflows/ci.yml          pipeline de GitHub Actions
build.gradle / settings.gradle    configuracion de Gradle
src/test/java/runner/Runner.java  runner JUnit 5 que lanza los features
src/test/resources/
  karate-config.js                URL base y timeouts
  features/                       escenarios Gherkin
  helpers/                        features auxiliares (llevar el robot a un estado)
docs/trazabilidad.md              requisitos, escenarios e issues
```

## Ejecucion

Requiere JDK 17 o superior.

```bash
./gradlew clean test
```

Por etiqueta:

```bash
./gradlew test -Dkarate.options="--tags @smoketest"
./gradlew test -Dkarate.options="--tags @Issue-10"
./gradlew test -Dkarate.options="--tags @barista"
```

En Windows se usa `gradlew.bat` en lugar de `./gradlew`.

El reporte queda en `target/karate-reports/karate-summary.html`.

Para apuntar a otra instancia de la API se puede definir la variable de entorno `KARATE_BASE_URL`
(debe terminar en `/api/`).

## Etiquetas

- `@smoketest`: casos minimos que corre el pipeline en cada push y pull request.
- `@regression`: el resto de casos.
- `@Issue-N`: Issue de GitHub vinculado al escenario. El pipeline lo usa para comentar el resultado.
- `@REQ-XX-NN`: requisito que cubre el escenario.
- `@barista`, `@climatizacion`: agrupacion por ejercicio.

## Pipeline

`ci.yml` corre las pruebas en cada push y pull request a `main` o `develop` con la etiqueta `@smoketest`.
Tambien se puede lanzar a mano desde la pestana Actions indicando una etiqueta (por ejemplo `@Issue-10`);
en ese caso el pipeline comenta el resultado en el Issue y le cambia la etiqueta `status:passed` o `status:failed`.

## Nota sobre el tiempo de respuesta

La API esta en un plan gratuito de Render y si lleva tiempo inactiva la primera peticion puede tardar casi un minuto.
Por eso `karate-config.js` define timeouts de 60 segundos.
