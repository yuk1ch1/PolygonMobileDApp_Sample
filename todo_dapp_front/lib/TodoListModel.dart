//TodoListModel.dart
//パッケージをインポートする。
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:todo_dapp_front/smartcontract/TodoContract.g.dart';

class TodoListModel extends ChangeNotifier {
  List<Task> todos = [];
  bool isLoading = true;
  int? taskCount;
  final String _rpcUrl = "http://10.0.2.2:8545";
  final String _wsUrl = "ws://10.0.2.2:8545/";


  //自分のPRIVATE_KEYを追加してください。
  final String _privateKey = "";

  Web3Client? _client;

  Credentials? _credentials;
  EthereumAddress? _contractAddress;
  EthereumAddress? _ownAddress;
  TodoContract? _contract;

  TodoListModel() {
    init();
  }

  Future<void> init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  //スマートコントラクトの`ABI`を取得し、デプロイされたコントラクトのアドレスを取り出す。
  Future<void> getAbi() async {
    // コントラクトアドレスの取得
    _contractAddress = EthereumAddress.fromHex("0x5fbdb2315678afecb367f032d93f642f64180aa3");
  }

  //秘密鍵を渡して`Credentials`クラスのインスタンスを生成する。
  Future<void> getCredentials() async {
    // Private Keyを暗号化してる？
    _credentials = EthPrivateKey.fromHex(_privateKey);

    // アカウントアドレスを取得する？
    _ownAddress = await _credentials!.extractAddress();
  }

  //`_abiCode`と`_contractAddress`を使用して、スマートコントラクトのインスタンスを作成する。
  Future<void> getDeployedContract() async {
    // コントラクトオブジェクトを取得

    _contract = TodoContract(address: _contractAddress!, client: _client!, chainId: 31337);

    await getTodos();
  }

  getTodos() async {
    // _taskCount関数を呼び出してto-doの総数を取得しループを使って全てのto-do項目を取得してリストに追加
    BigInt totalTask = await _contract!.taskCount();
    taskCount = totalTask.toInt();
    todos.clear();
    for (var i = 0; i < totalTask.toInt(); i++) {
      var temp = await _contract!.todos(BigInt.from(i));

      if (temp.taskName.isNotEmpty) {
        todos.add(
          Task(
            id: temp.id.toInt(),
            taskName: temp.taskName,
            isCompleted: temp.isComplete
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

    final result = await _contract!.createTask(taskNameData, credentials: _credentials!);

    await getTodos();
  }

  //2.to-doを更新する機能
  updateTask(int id, String taskNameData) async {
    isLoading = true;
    notifyListeners();
    await _contract!.updateTask(BigInt.from(id), taskNameData, credentials: _credentials!);
    await getTodos();
  }

  //3.to-doの完了・未完了を切り替える機能
  toggleComplete(int id) async {
    isLoading = true;
    notifyListeners();

    await _contract!.toggleComplete(BigInt.from(id), credentials: _credentials!);

    await getTodos();
  }

  //4.to-doを削除する機能
  deleteTask(int id) async {
    isLoading = true;
    notifyListeners();

    await _contract!.deleteTask(BigInt.from(id), credentials: _credentials!);

    await getTodos();
  }
}

class Task {
  final int? id;
  final String? taskName;
  final bool? isCompleted;
  Task({this.id, this.taskName, this.isCompleted});
}