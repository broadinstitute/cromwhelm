workflow dockerWorkflow {
    call myTask
}

task myTask {
    command {
        echo "hello from PAPI"
    }

    runtime {
        docker: "ubuntu:latest"
    }

    output {
        String out = read_string(stdout())
    }
}