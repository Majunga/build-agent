FROM mcr.microsoft.com/windows/servercore:ltsc2022

WORKDIR /azp/

RUN curl "https://vstsagentpackage.azureedge.net/agent/3.246.0/vsts-agent-win-x64-3.246.0.zip" > "./agent.zip" \
    && powershell Expand-Archive -Path "agent.zip" -DestinationPath "\azp\agent" \
    && powershell remove-item "./agent.zip"

COPY ./start.ps1 ./

CMD powershell .\start.ps1