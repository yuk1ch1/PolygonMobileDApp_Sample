// TodoContract.sol
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import "hardhat/console.sol";

contract TodoContract {
    struct Task {
        uint256 id;
        string taskName;
        bool isComplete;
    }

    uint256 public taskCount = 0;
    mapping(uint256 => Task) public todos;
    //1.to-doを作成する機能
    event TaskCreated(string task, uint256 taskNumber);
    //2.to-doを更新する機能
    event TaskUpdated(string task, uint256 taskId);
    //3.to-doの完了・未完了を切り替える機能
    event TaskIsCompleteToggled(string task, uint256 taskId, bool isComplete);
    //4.to-doを削除する機能
    event TaskDeleted(uint256 taskNumber);

    function createTask(string memory _taskName) public {
        todos[taskCount] = Task(taskCount, _taskName, false);
        taskCount++;
        emit TaskCreated(_taskName, taskCount - 1);
    }

    function updateTask(uint256 _taskId, string memory _taskName) public {
        Task memory target = todos[_taskId];
        todos[_taskId] = Task(_taskId, _taskName, target.isComplete);
        emit TaskUpdated(_taskName, _taskId);
    }

    function toggleComplete(uint256 _taskId) public {
        Task memory target = todos[_taskId];
        todos[_taskId] = Task(_taskId, target.taskName, !target.isComplete);

        emit TaskIsCompleteToggled(
            target.taskName,
            _taskId,
            !target.isComplete
        );
    }

    function deleteTask(uint256 _taskId) public {
        delete todos[_taskId];
        emit TaskDeleted(_taskId);
    }
}
