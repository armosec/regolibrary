package armo_builtins
# import data.cautils as cautils
# import data.kubernetes.api.client as client

deny[msga] {
	pod := input[_]
    pod.kind == "Pod"
    sensitive_key_names := {"aws_access_key_id", "aws_secret_access_key", "azure_batchai_storage_account", "azure_batchai_storage_key",
                            "azure_batch_account", "azure_batch_key", "passwd","password", "username", "pwd", "cred", "token", "key", "cert"}
    key_name := sensitive_key_names[_]
    container := pod.spec.containers[_]
    env := container.env[_]
    contains(lower(env.name), key_name)
	isNotReference(env)
	msga := {
		"alertMessage": sprintf("Pod: %v has sensitive information in environment variables", [pod.metadata.name]),
		"alertScore": 9,
		"packagename": "armo_builtins",
          "alertObject": {
			"k8sApiObjects": [pod]
		}
     }
}

deny[msga] {
	wl := input[_]
	spec_template_spec_patterns := {"Deployment","ReplicaSet","DaemonSet","StatefulSet","Job"}
	spec_template_spec_patterns[wl.kind]

    sensitive_key_names := {"aws_access_key_id", "aws_secret_access_key", "azure_batchai_storage_account", "azure_batchai_storage_key",
                            "azure_batch_account", "azure_batch_key", "passwd","password", "username", "pwd", "cred", "token", "key", "cert"}
    key_name := sensitive_key_names[_]
    container := wl.spec.template.spec.containers[_]
    env := container.env[_]
    contains(lower(env.name), key_name)
	isNotReference(env)
	msga := {
		"alertMessage": sprintf("%v: %v has sensitive information in environment variables", [wl.kind, wl.metadata.name]),
		"alertScore": 9,
		"packagename": "armo_builtins",
          "alertObject": {
			"k8sApiObjects": [wl]
		}
     }
}

deny[msga] {
	wl := input[_]
	wl.kind == "CronJob"
    sensitive_key_names := {"aws_access_key_id", "aws_secret_access_key", "azure_batchai_storage_account", "azure_batchai_storage_key",
                            "azure_batch_account", "azure_batch_key", "passwd","password", "username", "pwd", "cred", "token", "key", "cert"}
    key_name := sensitive_key_names[_]
	container := wl.spec.jobTemplate.spec.template.spec.containers[_]
    env := container.env[_]
    contains(lower(env.name), key_name)
	isNotReference(env)
	msga := {
		"alertMessage": sprintf("Cronjob: %v has sensitive information in environment variables", [wl.metadata.name]),
		"alertScore": 9,
		"packagename": "armo_builtins",
          "alertObject": {
			"k8sApiObjects": [wl]
		}
     }
}



isNotReference(env)
{
	not env.valueFrom.secretKeyRef
	not env.valueFrom.configMapKeyRef
}
