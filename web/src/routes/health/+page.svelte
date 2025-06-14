<script lang="ts">
	import { apiHealth } from '$lib/apiClient';

	let apiHealthPromise = $state(apiHealth());
</script>

{#await apiHealthPromise}
	<h1>loading</h1>
{:then res}
	<h1>{res.data as string}</h1>
{:catch err}
	{err}
{/await}
