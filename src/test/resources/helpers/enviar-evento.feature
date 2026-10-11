@ignore
Feature: Enviar un evento al Barista Bot

  Scenario: Enviar el evento recibido en la variable evento
    Given url baseUrl
    And path 'barista-bot/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: '#(evento)' }
    When method post
    Then status 200
    And match response.valida == true
