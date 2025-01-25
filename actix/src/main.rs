use actix_web::{ get, App, HttpServer, Responder, HttpResponse};

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello, Actix web here")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {


    HttpServer::new(|| {
        App::new()
            .service(hello)
    }).bind(("127.0.0.1", 8080))?.run().await
}
