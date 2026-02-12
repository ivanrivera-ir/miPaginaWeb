pipeline {
    agent any
    stages {
        stage('Construir Imagen') {
            steps {
                script {
                    // Construye la imagen etiquetada como 'mi-web:latest'
                    sh 'docker build -t mi-web:latest .'
                }
            }
        }
        stage('Desplegar') {
            steps {
                script {
                    // Detiene y borra el contenedor viejo si existe
                    sh 'docker stop web-server || true'
                    sh 'docker rm web-server || true'
                    // Corre el nuevo contenedor en el puerto 80 del HOST
                    sh 'docker run -d --name web-server -p 80:80 mi-web:latest'
                }
            }
        }
    }
}
