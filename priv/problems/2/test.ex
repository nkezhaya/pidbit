nil = ProcRegistry.start_link(MyModule)

%{status: "success"}
|> JSON.encode!()
|> IO.puts()
