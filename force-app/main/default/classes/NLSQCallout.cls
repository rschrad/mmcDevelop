public abstract class NLSQCallout {
    protected HttpResponse sendRequest(HttpRequest request) {
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

    protected HttpRequestBuilder getBuilder() {
        return new HttpRequestBuilder();
    }

    public class HttpRequestBuilder {
        private String endpoint;
        private String method;
        private String body;
        // prettier-ignore
        private HttpRequestBuilder() {} //NOPMD
        public void setEndpoint(String endpoint) {
            this.endpoint = endpoint;
        }

        public void setMethod(String method) {
            this.method = method;
        }

        public void setBody(String body) {
            this.body = body;
        }

        public HttpRequest build() {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(this.endpoint);
            request.setMethod(this.method);
            request.setBody(this.body);

            return request;
        }
    }
}