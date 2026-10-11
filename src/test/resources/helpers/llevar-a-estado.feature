@ignore
Feature: Llevar al Barista Bot a un estado inicial conocido

  # Recibe la variable estadoObjetivo. Reinicia el robot (queda en "En Espera")
  # y recorre la ruta de eventos validos necesaria para llegar a ese estado.

  Scenario: Reiniciar y avanzar hasta el estado objetivo
    * def rutas =
      """
      {
        "En Espera": [],
        "Moliendo": ["Iniciar Pedido"],
        "Calentando Agua": ["Iniciar Pedido", "Terminar Molienda"],
        "Sirviendo": ["Iniciar Pedido", "Terminar Molienda", "Alcanzar Temperatura"],
        "Error de Insumos": ["Iniciar Pedido", "Sin Ingredientes"]
      }
      """
    * def eventos = rutas[estadoObjetivo]
    * match eventos == '#array'

    Given url baseUrl
    And path 'barista-bot/reiniciar'
    When method post
    Then status 200
    And match response.estadoActual == 'En Espera'

    * def pasos = karate.map(eventos, function(e){ return { evento: e } })
    * if (pasos.length > 0) karate.call('classpath:helpers/enviar-evento.feature', pasos)

    Given url baseUrl
    And path 'barista-bot/estado'
    And header Accept = 'application/json'
    When method get
    Then status 200
    And match response.estadoActual == estadoObjetivo
