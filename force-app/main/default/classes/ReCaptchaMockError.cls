global class ReCaptchaMockError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success": false}');

        return res;
    }
}