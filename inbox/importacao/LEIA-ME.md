# Importação — material cru da sua empresa

Joga aqui dentro qualquer coisa que descreva o seu negócio e que você queira que o Claude leia: contrato, proposta antiga, planilha de clientes, export do CRM, print de painel, apresentação, briefing.

Não precisa organizar. Não precisa renomear. É pra ser bagunça mesmo.

## Esta pasta fica fora do git de propósito

Material cru costuma vir com coisa que não pode ir pra nuvem: chave de API dentro de um `.env` esquecido, CPF de cliente numa planilha, valor de contrato, senha anotada num documento.

Então: **nada daqui é enviado pro GitHub.** Nem por acidente.

## Como o conteúdo daqui vira parte do sistema

O Claude lê o que está aqui, destila o que interessa e escreve nos lugares certos — `_contexto/`, `empresas/<nome>/`. **O destilado sobe; o cru fica.**

Se você quiser versionar um arquivo específico daqui, mova ele pra fora desta pasta. Aí ele passa pelo scanner do `/syncar`, que aborta o commit se achar credencial dentro.
