// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/EdpModulo4.sol";

contract KipuBankTest is Test {
    KipuBank kipuBank;
    address user1;
    address user2;

    uint256 initialBankCap = 100 ether;

    function setUp() public {
        kipuBank = new KipuBank(initialBankCap);
        user1 = address(0x1);
        user2 = address(0x2);
        vm.deal(user1, 50 ether);
        vm.deal(user2, 52 ether);
    }

    function testInitialSetup() public {
        assertEq(kipuBank.i_bankCap(), initialBankCap);
        assertEq(kipuBank.bankCapCollected(), 0);
    }

    function testDepositSuccess() public {
        vm.prank(user1);
        kipuBank.deposit{value: 10 ether}(user1);

        assertEq(kipuBank.viewBankAmount(user1), 10 ether);
        assertEq(kipuBank.bankCapCollected(), 10 ether);
    }

    function testDepositOverCap () public {
        vm.prank(user1);
        kipuBank.deposit{value: 50 ether}(user1);

        vm.prank(user2);
        vm.expectRevert(bytes("Limite de ETH superado"));
        kipuBank.deposit{value: 52 ether}(user1);
    }       

function testWithdrawSuccess() public {
        vm.prank(user1);
        kipuBank.deposit{value: 10 ether}(user1);

        vm.prank(user1);
        kipuBank.withdraw(5 ether);

        assertEq(kipuBank.viewBankAmount(user1), 5 ether);
        assertEq(kipuBank.bankCapCollected(), 5 ether);
    }

    function testWithdrawRevertsIfOverBalance() public {
        vm.prank(user1);
        kipuBank.deposit{value: 5 ether}(user1);

        vm.prank(user1);
        vm.expectRevert(bytes("Saque indisponivel ou acima do limite"));
        kipuBank.withdraw(6 ether);
    }

    function testWithdrawRevertsIfOverLimit() public {
        vm.prank(user1);
        kipuBank.deposit{value: 20 ether}(user1);

        vm.prank(user1);
        vm.expectRevert(bytes("Saque indisponivel ou acima do limite"));
        kipuBank.withdraw(11 ether);
    }

    function testViewBankAmount() public {
        vm.prank(user2);
        kipuBank.deposit{value: 7 ether}(user2);

        assertEq(kipuBank.viewBankAmount(user2), 7 ether);
    }

}