@api @climatizacion @tabla-de-decision
Feature: Controlador de climatizacion inteligente segun tabla de decision
  Como tecnico de calidad
  Quiero verificar las reglas de decision del controlador de climatizacion
  Para asegurar que cada combinacion de condiciones produce la accion correcta

  # Condiciones, en el orden en que se envian en el arreglo "valores":
  #   C1  Temperatura interior mayor a 26 grados
  #   C2  Presencia humana activa detectada
  #   C3  Puertas o ventanas abiertas por mas de 3 minutos
  #
  # Tabla de decision (la API devuelve reglaIndex empezando en 0):
  #   Regla 1 (index 0): C3 = V, sin importar C1 y C2 -> Apagar sistema de climatizacion y emitir alerta sonora
  #   Regla 2 (index 1): C1 = V, C2 = V, C3 = F       -> Encender aire acondicionado en modo refrigeracion
  #   Regla 3 (index 2): C1 = V, C2 = F, C3 = F       -> Mantener en modo de bajo consumo energetico
  #   Regla 4 (index 3): C1 = F, C3 = F               -> Mantener sistema apagado

  @smoketest @Issue-13 @REQ-CL-01
  Scenario: Consultar la definicion con las condiciones y el total de reglas
    Given url baseUrl
    And path 'decision/climatizacion/definicion'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.condiciones == '#[3]'
    And match response.condiciones[0] contains 'Temperatura'
    And match response.condiciones[1] contains 'Presencia'
    And match response.condiciones[2] contains 'abiertas'
    And match response.totalReglas == 4

  @regression @Issue-14 @REQ-CL-02
  Scenario Outline: Regla 1 - puertas abiertas apaga el sistema y emite alerta (<temperatura>, <presencia>, <apertura>)
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: [<temperatura>, <presencia>, <apertura>] }
    When method post
    Then status 200
    And match response.accion == 'Apagar sistema de climatización y emitir alerta sonora'
    And match response.reglaIndex == 0
    And match response.noDefinida == false
    And match response.valores == [<temperatura>, <presencia>, <apertura>]

    Examples:
      | temperatura | presencia | apertura |
      | false       | false     | true     |
      | false       | true      | true     |
      | true        | false     | true     |
      | true        | true      | true     |

  @smoketest @Issue-15 @REQ-CL-03
  Scenario: Regla 2 - calor, presencia y puertas cerradas enciende la refrigeracion
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: [true, true, false] }
    When method post
    Then status 200
    And match response.accion == 'Encender aire acondicionado en modo refrigeración'
    And match response.reglaIndex == 1
    And match response.noDefinida == false

  @regression @Issue-16 @REQ-CL-04
  Scenario: Regla 3 - calor sin presencia y puertas cerradas mantiene bajo consumo
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: [true, false, false] }
    When method post
    Then status 200
    And match response.accion == 'Mantener en modo de bajo consumo energético'
    And match response.reglaIndex == 2
    And match response.noDefinida == false

  @regression @Issue-17 @REQ-CL-05
  Scenario Outline: Regla 4 - sin calor y puertas cerradas mantiene el sistema apagado (<temperatura>, <presencia>, <apertura>)
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: [<temperatura>, <presencia>, <apertura>] }
    When method post
    Then status 200
    And match response.accion == 'Mantener sistema apagado'
    And match response.reglaIndex == 3
    And match response.noDefinida == false

    Examples:
      | temperatura | presencia | apertura |
      | false       | true      | false    |
      | false       | false     | false    |

  @regression @Issue-18 @REQ-CL-06
  Scenario: Rechazar una evaluacion con menos valores de los esperados
    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: [true] }
    When method post
    Then status 400
    And match response.error == 'Se esperaban 3 valores booleanos'

  @regression @Issue-19 @REQ-CL-07
  Scenario: Las evaluaciones quedan registradas en el historial y se pueden reiniciar
    Given url baseUrl
    And path 'decision/climatizacion/reiniciar'
    When method post
    Then status 200
    And match response.ok == true

    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: [true, true, false] }
    When method post
    Then status 200

    Given url baseUrl
    And path 'decision/climatizacion/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: [false, false, false] }
    When method post
    Then status 200

    Given url baseUrl
    And path 'decision/climatizacion/definicion'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.historial == '#[2]'
    And match response.historial[0].reglaIndex == 1
    And match response.historial[1].reglaIndex == 3

    Given url baseUrl
    And path 'decision/climatizacion/reiniciar'
    When method post
    Then status 200

    Given url baseUrl
    And path 'decision/climatizacion/definicion'
    When method get
    Then status 200
    And match response.historial == []
