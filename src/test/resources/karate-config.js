function fn() {
  // La URL se puede cambiar con la variable de entorno KARATE_BASE_URL
  var envUrl = java.lang.System.getenv('KARATE_BASE_URL');

  var config = {
    baseUrl: envUrl ? envUrl : 'https://taller-de-tecnicas-de-prueba-de-caja.onrender.com/api/'
  };

  // El servicio esta en un plan gratuito de Render y la primera peticion
  // puede tardar casi un minuto si el servidor estaba dormido.
  karate.configure('connectTimeout', 60000);
  karate.configure('readTimeout', 60000);
  return config;
}
