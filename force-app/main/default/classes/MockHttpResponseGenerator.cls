@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    
    String requestURL { get; set; }
    String requestMethod { get; set; }
    String respBody { get; set; }
    Integer respStatusCode { get; set; }
    String respContentType { get; set; }
    
    global MockHttpResponseGenerator(String reqURL, String reqMethod, String respBody, 
                                     String contentType, Integer statusCode) 
    {
        this.requestURL = reqURL;
        this.requestMethod = reqMethod;
        this.respBody = respBody;
        this.respStatusCode = statusCode;
        this.respContentType = contentType;
    }
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', this.respContentType);
        res.setBody(this.respBody);
        res.setStatusCode(this.respStatusCode);
        return res;
    }
    
}