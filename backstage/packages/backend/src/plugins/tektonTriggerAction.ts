import { createTemplateAction } from '@backstage/plugin-scaffolder-backend';

export const createTriggerTektonAction = () => {
  return createTemplateAction<{
    pipelineName: string;
    namespace: string;
    params: Record<string, string>;
  }>({
    id: 'trigger:tekton',
    description: 'Triggers a Tekton pipeline run',
    schema: {
      input: {
        type: 'object',
        required: ['pipelineName', 'namespace'],
        properties: {
          pipelineName: {
            title: 'Pipeline Name',
            type: 'string',
          },
          namespace: {
            title: 'Namespace',
            type: 'string',
          },
          params: {
            title: 'Pipeline Parameters',
            type: 'object',
          },
        },
      },
    },
    async handler(ctx) {
      const { pipelineName, namespace, params } = ctx.input;

      ctx.logger.info(`Triggering Tekton pipeline: ${pipelineName} in ${namespace}`);

      // In production, this would call the Kubernetes API or Tekton CLI
      // to create a PipelineRun resource.
      const pipelineRun = {
        apiVersion: 'tekton.dev/v1beta1',
        kind: 'PipelineRun',
        metadata: {
          generateName: `${pipelineName}-`,
          namespace,
        },
        spec: {
          pipelineRef: {
            name: pipelineName,
          },
          params: Object.entries(params || {}).map(([name, value]) => ({
            name,
            value,
          })),
        },
      };

      ctx.logger.info(`PipelineRun spec: ${JSON.stringify(pipelineRun)}`);

      // Placeholder for actual K8s API call
      // const k8sClient = new KubernetesClient();
      // await k8sClient.createPipelineRun(pipelineRun);

      ctx.output('pipelineRunName', `${pipelineRun.metadata.generateName}xxxx`);
    },
  });
};
