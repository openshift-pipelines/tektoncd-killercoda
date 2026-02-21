# Build an app without a Dockerfile

Let's create a minimal application and build it with Buildpacks.

## Create a simple Go application

```bash
cat <<APPEOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: create-source
spec:
  workspaces:
    - name: output
  steps:
    - name: create
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        mkdir -p \$(workspaces.output.path)/src
        cat > \$(workspaces.output.path)/src/main.go << 'GO'
        package main
        import (
            "fmt"
            "net/http"
        )
        func main() {
            http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
                fmt.Fprintf(w, "Hello from Buildpacks!")
            })
            fmt.Println("Starting server on :8080")
            http.ListenAndServe(":8080", nil)
        }
        GO
        cat > \$(workspaces.output.path)/src/go.mod << 'MOD'
        module example.com/hello
        go 1.21
        MOD
        echo "Source created!"
        ls -la \$(workspaces.output.path)/src/
APPEOF

echo "Source creation Task ready."
echo ""
echo "No Dockerfile needed! Buildpacks will:"
echo "  1. Detect the Go application"
echo "  2. Install Go compiler"
echo "  3. Compile the binary"
echo "  4. Create a minimal runtime image"
```

## Verify

```bash
kubectl get task create-source &>/dev/null
```
