/** @type {import('@hey-api/openapi-ts').UserConfig} */
export default {
	output: 'src/lib/apiClient',
	plugins: [{ baseUrl: false, name: '@hey-api/client-fetch' }]
};
