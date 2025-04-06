/**
 *Submitted for verification at Etherscan.io on 2025-01-03
*/

// SPDX-License-Identifier: MIT
// Licenca MIT para indicar que o codigo e de uso livre, desde que respeitadas as condicoes da licenca.

pragma solidity ^0.8.19;
// Declara a versao do Solidity usada no contrato.

contract KipuBank {
    // Declaracao do contrato chamado "KipuBank".

    address public owner;
    // Variavel publica que armazenaria o endereco do proprietario do contrato (nao foi inicializada, mas seria util para controle administrativo).

    uint public immutable bankCap;
    // Limite maximo de ETH que o banco pode armazenar. e imutavel, ou seja, definido apenas uma vez no construtor.

    uint public bankCapCollected;
    // Quantidade total de ETH atualmente armazenada no banco.

    mapping(address => uint) public bankAmount;
    // Um mapeamento que associa enderecos de clientes ao valor depositado por eles no banco.

    uint public constant withdrawLimit = 10 ether;
    // Limite fixo de saque por cliente, definido como 10 ETH.

    // Declaracao de erros personalizados para situacoes especificas.
    error insufficientBalance(string reason);
    // Erro lancado quando um deposito excede o limite do banco.

    error withdrawDenied(string reason);
    // Erro lancado quando um saque e negado devido a saldo insuficiente ou exceder o limite de saque.

    error transferFailed(string reason);
    // Erro lancado quando uma transferencia de ETH falha.

    // Declaracao de eventos para monitorar acoes importantes.
    event depositSuccessfull(address destinationAddress, uint bankAmount);
    // Evento emitido quando um deposito e realizado com sucesso.

    event withdrawSuccessfull(address destinationAddress, uint bankAmount);
    // Evento emitido quando um saque e realizado com sucesso.

    // --------------------------------
    // 1 - Configuracao Inicial
    constructor(uint _bankCap) {
        // Construtor que inicializa o limite maximo (bankCap) do banco.
        bankCap = _bankCap;
    }

    // --------------------------------
    // MODIFIERS (modificadores de funcao)

    modifier checkDeposit() {
        // Modificador que verifica se o deposito ultrapassaria o limite do banco.
        if (bankCap < msg.value + bankCapCollected) {
            revert insufficientBalance("Limite de ETH superado");
            // Lanca um erro se o limite do banco for excedido.
        }
        _;
        // Continua a execucao da funcao caso a condicao seja satisfeita.
    }

    modifier checkWithdraw(uint withdrawValue) {
        // Modificador que verifica se o saque e valido.
        if (withdrawValue > bankAmount[msg.sender] || withdrawValue > withdrawLimit) {
            revert withdrawDenied("Saque indisponivel ou acima do limite");
            // Lanca um erro se o saque exceder o saldo disponivel ou o limite de saque.
        }
        _;
        // Continua a execucao da funcao caso a condicao seja satisfeita.
    }

    // --------------------------------
    // 2 - Deposito de Fundos
    // Funcao que permite ao cliente depositar ETH em sua conta.
    function deposit(address destinationAddres) public payable checkDeposit {
        // Atualiza o saldo do cliente (endereco de destino) com o valor depositado.
        bankAmount[destinationAddres] += msg.value;
        
        // Atualiza o total coletado pelo banco.
        bankCapCollected += msg.value;
        
        // Emite o evento de deposito bem-sucedido.
        emit depositSuccessfull(destinationAddres, msg.value);
    }

    // --------------------------------
    // 3 - Retirada de Fundos
    // Funcao que permite ao cliente sacar ETH de sua conta.
    // O valor a ser retirado deve ser menor ou igual ao saldo disponivel e ao limite de saque.
    function withdraw(uint withdrawValue) public checkWithdraw(withdrawValue) {
        // Envia o valor solicitado para o endereco do cliente.
        (bool sent, bytes memory data) = msg.sender.call{value: withdrawValue}("");

        if (sent == false) {
            // Lanca um erro caso a transferencia falhe.
            revert transferFailed("Falha na transacao");
        }

        // Deduz o valor sacado do saldo do cliente.
        bankAmount[msg.sender] -= withdrawValue;

        // Atualiza o total coletado pelo banco.
        bankCapCollected -= withdrawValue;

        // Emite o evento de saque bem-sucedido.
        emit withdrawSuccessfull(msg.sender, withdrawValue);
    }

    // --------------------------------
    // 4 - Consulta de Saldo
    // Funcao que retorna o saldo de um cliente com base em seu endereco.
    function viewBankAmount(address _bankAddress) public view returns (uint) {
        return bankAmount[_bankAddress];
        // Retorna o saldo associado ao endereco informado.
    }
}