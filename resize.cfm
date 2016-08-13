<cfscript>
pool = new pool();

while(!pool.hasFreeThread() and !pool.isAtMaxThreads()){
	pool.new();
}
</cfscript>