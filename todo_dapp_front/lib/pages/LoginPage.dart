import 'package:flutter/material.dart';
import 'package:todo_dapp_front/utils/routes.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';

var connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
        name: 'My App',
        description: 'An app for converting pictures to NFT',
        url: 'https://walletconnect.org',
        icons: [
          'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ]
    )
);

EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // ignore: prefer_typing_uninitialized_variables
  var _session, _uri, _signature;

  loginUsingMetamask(BuildContext context) async {

    if (!connector.connected) {
      try {
        var session = await connector.createSession(onDisplayUri: (uri) async {
          _uri = uri;
          await launchUrlString(uri, mode: LaunchMode.externalApplication);
        });

        setState(() {
          _session = session;
        });
        Navigator.pushNamed(context, '/todolist');
      } catch (error) {
        print(error);
      }
    } else {
      print("already connected");
    }
  }

  signMessageWithMetamask(BuildContext context, String message) async {
    if (connector.connected) {
      try {
        launchUrlString(_uri, mode: LaunchMode.externalApplication);
        var signature = await provider.personalSign(message: message, address: _session.accounts[0], password: "");

        setState(() {
          _signature = signature;
        });
      }
      catch (error) {
        print(error);
      }
    }
  }

  getNetworkName(chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goerli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      case 80001:
        return 'Mumbai Testnet';
      default:
        return 'Unknown Chain';
    }
  }

  @override
  Widget build(BuildContext context) {
    connector.on(
        'connect',
            (session) => setState(
              () {
            _session = _session;
            print(_session!.accounts[0]);
            print(_session!.chainId);
          },
        ));
    connector.on(
        'session_update',
            (SessionStatus payload) => setState(() {
          _session = payload;
          print(payload.accounts[0]);
          print(payload.chainId);
        }
        )
    );
    connector.on(
        'disconnect',
            (payload) => setState(() {
          print(_session!.accounts[0]);
          print(_session!.chainId);
          _session = null;
        }));
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: (_session != null)
            ? Container(
            child: Text("接続済み"))
            : ElevatedButton(
            onPressed: () => loginUsingMetamask(context),
            child: const Text("Connect with Metamask")
        )
    );
  }
}
