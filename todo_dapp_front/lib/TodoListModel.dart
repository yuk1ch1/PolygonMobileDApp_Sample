//TodoListModel.dart
//パッケージをインポートする。
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class TodoListModel extends ChangeNotifier {
  List<Task> todos = [];
  bool isLoading = true;
  int? taskCount;
  final String _rpcUrl = "http://10.0.2.2:8545";
  final String _wsUrl = "ws://127.0.0.1:8545/";


  //自分のPRIVATE_KEYを追加してください。
  final String _privateKey =
      "";

  Web3Client? _client;
  String? _abiCode;

  Credentials? _credentials;
  EthereumAddress? _contractAddress;
  EthereumAddress? _ownAddress;
  DeployedContract? _contract;

  ContractFunction? _taskCount;
  ContractFunction? _todos;
  ContractFunction? _createTask;
  ContractFunction? _updateTask;
  ContractFunction? _deleteTask;
  ContractFunction? _toggleComplete;

  TodoListModel() {
    init();
  }

  Future<void> init() async {
    // _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
    //   return IOWebSocketChannel.connect(Uri.parse(_wsUrl)).cast<String>();
    // });
    _client = Web3Client(_rpcUrl, Client());

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  //スマートコントラクトの`ABI`を取得し、デプロイされたコントラクトのアドレスを取り出す。
  Future<void> getAbi() async {
    // abiファイルの情報をstringで取り出す
    String abiStringFile = await rootBundle
        .loadString("smartcontract/TodoContract.json");
    // jsonデータを取得
    var jsonAbi = jsonDecode(abiStringFile);
    // jsonデータからabiデータを抽出する
    _abiCode = jsonEncode(jsonAbi["abi"]);

    // コントラクトアドレスの取得
    _contractAddress =
        EthereumAddress.fromHex("0x5fbdb2315678afecb367f032d93f642f64180aa3");
    // EthereumAddress.fromHex(jsonAbi["networks"]["2"]["address"]);
  }

  //秘密鍵を渡して`Credentials`クラスのインスタンスを生成する。
  Future<void> getCredentials() async {

    // _credentials = await _client!.credentialsFromPrivateKey(_privateKey);
    // Private Keyを暗号化してる？
    _credentials = EthPrivateKey.fromHex(_privateKey);

    // アカウントアドレスを取得する？
    _ownAddress = await _credentials!.extractAddress();
  }

  //`_abiCode`と`_contractAddress`を使用して、スマートコントラクトのインスタンスを作成する。
  Future<void> getDeployedContract() async {
    // コントラクトオブジェクトを取得

    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, "TodoContract"), _contractAddress!);
    _taskCount = _contract!.function("taskCount");
    _updateTask = _contract!.function("updateTask");
    _createTask = _contract!.function("createTask");
    _deleteTask = _contract!.function("deleteTask");
    _toggleComplete = _contract!.function("toggleComplete");
    _todos = _contract!.function("todos");
    await getTodos();
  }

  getTodos() async {
    // _taskCount関数を呼び出してto-doの総数を取得しループを使って全てのto-do項目を取得してリストに追加
    List totalTaskList = await _client!.call(contract: _contract!, function: _taskCount!, params: []);

    BigInt totalTask = totalTaskList[0];
    taskCount = totalTask.toInt();
    todos.clear();
    for (var i = 0; i < totalTask.toInt(); i++) {
      var temp = await _client!.call(
          contract: _contract!, function: _todos!, params: [BigInt.from(i)]);
      if (temp[1] != "") {
        todos.add(
          Task(
            id: (temp[0] as BigInt).toInt(),
            taskName: temp[1],
            isCompleted: temp[2]
          )
        );
      }
    }
    isLoading = false;
    todos = todos.reversed.toList();

    notifyListeners();
  }

  //1.to-doを作成する機能
  addTask(String taskNameData) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _createTask!,
        parameters: [taskNameData],
      ),
    );
    await getTodos();
  }

  //2.to-doを更新する機能
  updateTask(int id, String taskNameData) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _updateTask!,
        parameters: [BigInt.from(id), taskNameData],
      ),
    );
    await getTodos();
  }

  //3.to-doの完了・未完了を切り替える機能
  toggleComplete(int id) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _toggleComplete!,
        parameters: [BigInt.from(id)],
      ),
    );
    await getTodos();
  }

  //4.to-doを削除する機能
  deleteTask(int id) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _deleteTask!,
        parameters: [BigInt.from(id)],
      ),
    );
    await getTodos();
  }
}

class Task {
  final int? id;
  final String? taskName;
  final bool? isCompleted;
  Task({this.id, this.taskName, this.isCompleted});
}