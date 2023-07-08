import "forge-std/Script.sol";
import {Orderbook} from "../src/Orderbook.sol";

contract MyScript is Script {
    function run() public {
        uint deployerPrivateKey = vm.envUint("SCRIPT_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        Orderbook orderbook = new Orderbook();
        vm.stopBroadcast();
    }
}
