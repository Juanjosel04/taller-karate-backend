@api @barista @transicion-de-estados
Feature: Robot cafetero (Barista Bot) segun tabla de transicion de estados
  Como tecnico de calidad
  Quiero verificar las transiciones del Barista Bot expuestas por la API
  Para asegurar que solo se aceptan los eventos permitidos en cada estado

  # Estados: En Espera (S1), Moliendo (S2), Calentando Agua (S3), Sirviendo (S4), Error de Insumos (S5)
  # Antes de cada caso se usa helpers/llevar-a-estado.feature para dejar el robot en el estado inicial pedido.

  @smoketest @Issue-1 @REQ-BB-01
  Scenario: Consultar el estado inicial del robot
    Given url baseUrl
    And path 'barista-bot/estado'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.estadoActual == '#string'
    And match response.maquina.estados == ['En Espera', 'Moliendo', 'Calentando Agua', 'Sirviendo', 'Error de Insumos']
    And match response.maquina.eventos contains ['Iniciar Pedido', 'Terminar Molienda', 'Alcanzar Temperatura', 'Terminar Llenado', 'Sin Ingredientes', 'Recargar y Reiniciar']

  # ---------------------------------------------------------------
  # Transiciones validas
  # ---------------------------------------------------------------

  @smoketest @Issue-2 @REQ-BB-02
  Scenario: Iniciar pedido desde En Espera pasa a Moliendo
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'En Espera' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Iniciar Pedido' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'En Espera'
    And match response.estadoNuevo == 'Moliendo'
    And match response.valida == true

  @regression @Issue-3 @REQ-BB-02
  Scenario: Terminar molienda desde Moliendo pasa a Calentando Agua
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Moliendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Terminar Molienda' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Moliendo'
    And match response.estadoNuevo == 'Calentando Agua'
    And match response.valida == true

  @regression @Issue-4 @REQ-BB-02
  Scenario: Falta de ingredientes durante la molienda pasa a Error de Insumos
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Moliendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Moliendo'
    And match response.estadoNuevo == 'Error de Insumos'
    And match response.valida == true
    And match response.accion == 'Interrumpir flujo'

  @regression @Issue-5 @REQ-BB-02
  Scenario: Alcanzar temperatura desde Calentando Agua pasa a Sirviendo
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Calentando Agua' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Alcanzar Temperatura' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Calentando Agua'
    And match response.estadoNuevo == 'Sirviendo'
    And match response.valida == true

  @regression @Issue-6 @REQ-BB-02
  Scenario: Falta de ingredientes mientras se calienta el agua pasa a Error de Insumos
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Calentando Agua' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Calentando Agua'
    And match response.estadoNuevo == 'Error de Insumos'
    And match response.valida == true
    And match response.accion == 'Interrumpir flujo'

  @regression @Issue-7 @REQ-BB-02
  Scenario: Terminar llenado desde Sirviendo regresa a En Espera
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Sirviendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Terminar Llenado' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Sirviendo'
    And match response.estadoNuevo == 'En Espera'
    And match response.valida == true

  @regression @Issue-8 @REQ-BB-02
  Scenario: Falta de ingredientes mientras se sirve pasa a Error de Insumos
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Sirviendo' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Sin Ingredientes' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Sirviendo'
    And match response.estadoNuevo == 'Error de Insumos'
    And match response.valida == true
    And match response.accion == 'Interrumpir flujo'

  @regression @Issue-9 @REQ-BB-02
  Scenario: Recargar y reiniciar desde Error de Insumos regresa a En Espera
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Error de Insumos' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Recargar y Reiniciar' }
    When method post
    Then status 200
    And match response.estadoAnterior == 'Error de Insumos'
    And match response.estadoNuevo == 'En Espera'
    And match response.valida == true
    And match response.accion == 'Restaurar servicio'

  # ---------------------------------------------------------------
  # Transiciones invalidas: las 22 combinaciones estado-evento restantes
  # ---------------------------------------------------------------

  @regression @Issue-10 @REQ-BB-03
  Scenario Outline: El evento <evento> en el estado <estado> no cambia el estado del robot
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: '<estado>' }
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: '<evento>' }
    When method post
    Then status 200
    And match response.valida == false
    And match response.estadoAnterior == '<estado>'
    And match response.estadoNuevo == '<estado>'

    Given url baseUrl
    And path 'barista-bot/estado'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.estadoActual == '<estado>'

    Examples:
      | estado           | evento               |
      | En Espera        | Terminar Molienda    |
      | En Espera        | Alcanzar Temperatura |
      | En Espera        | Terminar Llenado     |
      | En Espera        | Sin Ingredientes     |
      | En Espera        | Recargar y Reiniciar |
      | Moliendo         | Iniciar Pedido       |
      | Moliendo         | Alcanzar Temperatura |
      | Moliendo         | Terminar Llenado     |
      | Moliendo         | Recargar y Reiniciar |
      | Calentando Agua  | Iniciar Pedido       |
      | Calentando Agua  | Terminar Molienda    |
      | Calentando Agua  | Terminar Llenado     |
      | Calentando Agua  | Recargar y Reiniciar |
      | Sirviendo        | Iniciar Pedido       |
      | Sirviendo        | Terminar Molienda    |
      | Sirviendo        | Alcanzar Temperatura |
      | Sirviendo        | Recargar y Reiniciar |
      | Error de Insumos | Iniciar Pedido       |
      | Error de Insumos | Terminar Molienda    |
      | Error de Insumos | Alcanzar Temperatura |
      | Error de Insumos | Terminar Llenado     |
      | Error de Insumos | Sin Ingredientes     |

  # ---------------------------------------------------------------
  # Validacion de entrada y reinicio
  # ---------------------------------------------------------------

  @regression @Issue-11 @REQ-BB-04
  Scenario: Rechazar un evento que no existe en la maquina
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Preparar Postre' }
    When method post
    Then status 400
    And match response.error == '#string'
    And match response.error contains 'Preparar Postre'

  @smoketest @Issue-12 @REQ-BB-05
  Scenario: Reiniciar el robot desde un estado intermedio lo devuelve a En Espera
    * call read('classpath:helpers/llevar-a-estado.feature') { estadoObjetivo: 'Calentando Agua' }
    Given url baseUrl
    And path 'barista-bot/reiniciar'
    And header Accept = 'application/json'
    When method post
    Then status 200
    And match response.estadoActual == 'En Espera'

    Given url baseUrl
    And path 'barista-bot/estado'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.estadoActual == 'En Espera'
    And match response.historial == []
