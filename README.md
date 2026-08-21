# GLAMP — IBITI Glamping Token

Token ERC-20 de fidelidade desenvolvido como atividade individual do módulo de Blockchain e Tokenização de Ativos (ADMD7/AD07), inspirado no contexto do projeto de parceria com a IBITI Glamping.

---

## 1. Problema e Proposta de Valor

Negócios de glamping (camping de luxo) enfrentam um desafio clássico de hospitality: **fidelização e recorrência**. O ticket médio é alto, a jornada de compra é longa (planejamento de viagem), e não existe um mecanismo nativo que recompense o hóspede por voltar, indicar amigos ou consumir serviços adicionais (trilhas guiadas, spa, gastronomia local) durante a estadia.

**Proposta de valor**: criar uma moeda de fidelidade programável — transparente, rastreável on-chain e transferível — que o hóspede acumula ao reservar/consumir e resgata por benefícios dentro do ecossistema IBITI (diárias, upgrades, experiências parceiras).

## 2. Tipo de Token: Utility Token

O GLAMP foi modelado como **utility token**, e não como governance ou stablecoin:

- **Não é stablecoin**: não há necessidade de paridade com ativo externo (dólar, real). O token não serve como reserva de valor, serve como crédito de consumo.
- **Não é governance (puro)**: nesta fase do projeto não há uma DAO ou tomada de decisão descentralizada real sendo modelada — daria poder de voto sobre decisões operacionais do glamping a hóspedes pontuais, o que seria over-engineering.
- **É utility**: tem função de uso direto e mensurável dentro do ecossistema — acesso a benefícios, resgates e descontos. É o padrão de mercado para loyalty tokens em hospitality/turismo.

Essa categoria de uso é validada pelo próprio material de referência da disciplina (glossário ERC-20 da Coinbase), que cita pontos de fidelidade como um dos usos canônicos do padrão ERC-20.

## 3. Parâmetros de Modelagem

| Parâmetro | Definição | Justificativa |
|---|---|---|
| **Nome** | IBITI Glamping Token | Vincula diretamente à marca |
| **Símbolo** | `GLAMP` | Curto, memorável, evita confusão com outros tickers |
| **Padrão** | ERC-20 | Compatibilidade com wallets/exchanges, simplicidade de implementação |
| **Supply total** | 10.000.000 GLAMP (hard cap fixo) | Escassez e previsibilidade — evita diluição descontrolada, importante para a confiança do hóspede no valor do saldo |
| **Divisibilidade** | 18 casas decimais (padrão ERC-20) | Permite frações pequenas (ex: cashback de 2,5% sobre uma diária) |
| **Mecanismo de emissão** | Mint controlado, sob demanda, restrito ao `owner` | Simula um programa de pontos real: emissão gradual conforme reservas confirmadas, respeitando o teto de 10M |

## 4. Circulação, Transferência e Permissões

- **Como circula**: o hóspede recebe GLAMP como cashback ao confirmar reserva (ex: 5% do valor pago, convertido em token a uma taxa fixa definida off-chain) ou por indicação de amigos.
- **Transferência**: função `transfer` padrão ERC-20 — o hóspede pode enviar tokens para outra carteira (presentear alguém, consolidar saldo).
- **Permissões**:
  - `mint`: apenas o `owner` (carteira administrativa da IBITI) pode cunhar novos tokens, respeitando o `MAX_SUPPLY`.
  - `burn`: disponível via `ERC20Burnable` — usada quando o hóspede resgata um benefício, controlando a circulação.
  - `transfer` / `approve` / `transferFrom`: padrão ERC-20, sem restrição adicional, mantendo compatibilidade e simplicidade.

## 5. Relação com o Ecossistema

O GLAMP é o elo entre a **camada de reservas** (app/site de booking da IBITI) e a **camada de benefícios** (upgrades de acomodação, experiências parceiras, descontos em consumo local). Funciona como registro auditável e portátil de fidelidade: diferente de um programa de pontos tradicional (fechado, controlado só pela empresa), o saldo vive na wallet do hóspede, é verificável publicamente on-chain, e pode futuramente compor parcerias com outros negócios de turismo da região.

---

## 6. Contrato Inteligente

Implementado em Solidity `^0.8.20`, usando OpenZeppelin (`ERC20`, `ERC20Burnable`, `Ownable`) como base auditada.

Código completo: [`contracts/GlampToken.sol`](./contracts/GlampToken.sol)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";

/// @title GLAMP - IBITI Glamping Loyalty Token
/// @notice Utility token de fidelidade: mint controlado pela IBITI (owner),
/// hospede pode transferir e queimar (resgate de beneficios).
contract GlampToken is ERC20, ERC20Burnable, Ownable {

    // Supply maximo: 10.000.000 GLAMP (com 18 casas decimais)
    uint256 public constant MAX_SUPPLY = 10_000_000 * 10 ** 18;

    constructor(address initialOwner)
        ERC20("IBITI Glamping Token", "GLAMP")
        Ownable(initialOwner)
    {}

    /// @notice Cunha novos tokens (ex: cashback de reserva confirmada).
    /// @dev Restrito ao owner (carteira administrativa da IBITI).
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "GLAMP: excede supply maximo");
        _mint(to, amount);
    }
}
```

## 7. Deploy e Testes — Rede Sepolia

**Ferramentas**: Remix IDE + MetaMask (Injected Provider) conectados à testnet Sepolia.

**Endereço do contrato**: [`0x2977559e80173b626d7e26fbebf88cf9ede15c77`](https://sepolia.etherscan.io/address/0x2977559e80173b626d7e26fbebf88cf9ede15c77)

| Etapa | Descrição | Transaction Hash |
|---|---|---|
| **Deploy** | Criação do contrato, `initialOwner` = carteira administrativa | [`0xe53d041ccc78e7b230f0d7c85bc384b7fc96aa40650b0988efa5c2a0b3129d7e`](https://sepolia.etherscan.io/tx/0xe53d041ccc78e7b230f0d7c85bc384b7fc96aa40650b0988efa5c2a0b3129d7e) |
| **Mint** | Cunhagem de 1.000 GLAMP para a carteira do owner | [`0x2f28cce52c1dab0ce3169f9f955fba9360d2c8cb674935d44262f434235a2802`](https://sepolia.etherscan.io/tx/0x2f28cce52c1dab0ce3169f9f955fba9360d2c8cb674935d44262f434235a2802) |
| **Transfer** | Transferência de 100 GLAMP entre duas carteiras distintas | [`0x3dca55abe83ae3b43e9deadee70375e2d4ecdd54fb25b22f7c59d0edbbb646ae`](https://sepolia.etherscan.io/tx/0x3dca55abe83ae3b43e9deadee70375e2d4ecdd54fb25b22f7c59d0edbbb646ae) |

**Carteiras envolvidas**:
- Conta A (owner / origem): `0x3860D29d54b0D4e9825a079Fa1bd36C2A3f49B30`
- Conta B (destino): `0x791E7dA2...05a7d1707`


## 8. Vídeo de Demonstração

https://youtu.be/W2e20KsAGb8
](https://youtu.be/W2e20KsAGb8)
O vídeo apresenta: (1) a proposta de valor do token, (2) o contrato deployado no Sepolia Etherscan, e (3) uma transferência real entre duas carteiras.
