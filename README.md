# jenkins_test_project

Test project for jenkins in a 2022 NCU course.

## build instructions

```bash
## requires node >= 12.22.1
## 14 works to my knowledge
## requires quasar/cli >= 1.2.1
npm install -g @quasar/cli
## Install the dependencies
npm install

# Start the app in development mode (hot-code reloading, error reporting, etc.)
npx quasar dev

## Build the app for production
npx quasar build
```

## build using docker

```shell
docker build -t my-quasar-vue-app .
docker run -p 8080:80 my-quasar-vue-app 
```

Your Quasar-built Vue.js app should now be accessible at <http://localhost:8080>.
