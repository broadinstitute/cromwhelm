version 1.0

workflow dockerWorkflow {
    call myTask
}

task myTask {
    meta {
        volatile: true
    }
    
    command {
        echo "hello from PAPI"
    }

    runtime {
        docker: "ubuntu:latest"
        backend: "PAPIv2"
    }

    output {
        String out = read_string(stdout())
    }
}
