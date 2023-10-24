package k8s

import data.kubernetes.admission

deny[msg] {
    input.request.kind.kind == "Pod"
    image := input.request.object.spec.containers[_].image
    not startswith(image, "private-registry.io/")
    msg = sprintf("Invalid image registry for: %v", [image])
}

deny[msg] {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    container.securityContext.privileged
    msg = sprintf("Privileged container is not allowed: %v", [container.name])
}

deny[msg] {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation
    msg = sprintf("Privilege escalation is not allowed: %v", [container.name])
}
