FROM golang:alpine
WORKDIR /src
RUN apk add --update npm git
RUN go get -u github.com/jteeuwen/go-bindata/...
COPY ./webapp/package.json webapp/package.json
# --legacy-peer-deps because of error during npm install
# https://github.com/supasate/connected-react-router/issues/429#issuecomment-691620790
RUN cd ./webapp && \
    npm install --legacy-peer-deps
COPY . .
RUN cd ./webapp && \
    npm run build
RUN cd ./migrations && \
    go-bindata  -pkg migrations .
RUN go-bindata  -pkg tmpl -o ./tmpl/bindata.go  ./tmpl/ && \
    go-bindata  -pkg webapp -o ./webapp/bindata.go  ./webapp/build/...    

RUN go build -o /opt/featmap/featmap && \
    chmod 775 /opt/featmap/featmap

ENTRYPOINT cd /opt/featmap && ./featmap
