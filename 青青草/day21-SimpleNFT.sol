// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; // 声明编译器版本

interface IERC721 { // ERC721标准接口
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId); // NFT转账事件
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId); // NFT授权事件
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved); // 批量授权事件

    function balanceOf(address owner) external view returns (uint256); // 查询地址NFT数量
    function ownerOf(uint256 tokenId) external view returns (address); // 查询NFT所属地址

    function approve(address to, uint256 tokenId) external; // 授权地址操作NFT
    function getApproved(uint256 tokenId) external view returns (address); // 查询NFT授权地址

    function setApprovalForAll(address operator, bool approved) external; // 批量授权/取消
    function isApprovedForAll(address owner, address operator) external view returns (bool); // 检查批量授权

    function transferFrom(address from, address to, uint256 tokenId) external; // 转账NFT
    function safeTransferFrom(address from, address to, uint256 tokenId) external; // 安全转账NFT
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external; // 带数据安全转账
}

interface IERC721Receiver { // NFT接收验证接口
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4); // NFT接收回调
}

contract SimpleNFT is IERC721 { // 实现ERC721的NFT合约
    string public name; // NFT名称
    string public symbol; // NFT符号

    uint256 private _tokenIdCounter = 1; // NFT编号计数器（从1开始）

    mapping(uint256 => address) private _owners; // tokenId => 拥有者地址
    mapping(address => uint256) private _balances; // 地址 => NFT持有数量
    mapping(uint256 => address) private _tokenApprovals; // tokenId => 授权地址
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 地址 => 操作者 => 授权状态
    mapping(uint256 => string) private _tokenURIs; // tokenId => 元数据链接

    constructor(string memory name_, string memory symbol_) { // 构造函数初始化名称和符号
        name = name_; // 赋值NFT名称
        symbol = symbol_; // 赋值NFT符号
    }

    function balanceOf(address owner) public view override returns (uint256) { // 实现查询NFT数量
        require(owner != address(0), "Zero address"); // 禁止查询零地址
        return _balances[owner]; // 返回地址NFT数量
    }

    function ownerOf(uint256 tokenId) public view override returns (address) { // 实现查询NFT所属
        address owner = _owners[tokenId]; // 获取tokenId拥有者
        require(owner != address(0), "Token doesn't exist"); // 检查NFT是否存在
        return owner; // 返回拥有者地址
    }

    function approve(address to, uint256 tokenId) public override { // 实现授权NFT
        address owner = ownerOf(tokenId); // 获取NFT拥有者
        require(to != owner, "Already owner"); // 禁止授权给自己
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized"); // 验证操作权限

        _tokenApprovals[tokenId] = to; // 记录授权地址
        emit Approval(owner, to, tokenId); // 触发授权事件
    }

    function getApproved(uint256 tokenId) public view override returns (address) { // 实现查询授权地址
        require(_owners[tokenId] != address(0), "Token doesn't exist"); // 检查NFT是否存在
        return _tokenApprovals[tokenId]; // 返回授权地址
    }

    function setApprovalForAll(address operator, bool approved) public override { // 实现批量授权
        require(operator != msg.sender, "Self approval"); // 禁止授权给自己
        _operatorApprovals[msg.sender][operator] = approved; // 记录批量授权状态
        emit ApprovalForAll(msg.sender, operator, approved); // 触发批量授权事件
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) { // 实现检查批量授权
        return _operatorApprovals[owner][operator]; // 返回批量授权状态
    }

    function transferFrom(address from, address to, uint256 tokenId) public override { // 实现转账NFT
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized"); // 验证操作权限
        _transfer(from, to, tokenId); // 执行转账逻辑
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override { // 实现安全转账
        safeTransferFrom(from, to, tokenId, ""); // 调用带空数据的安全转账
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override { // 实现带数据安全转账
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized"); // 验证操作权限
        _safeTransfer(from, to, tokenId, data); // 执行安全转账逻辑
    }

    function mint(address to, string memory uri) public { // 铸造NFT函数
        uint256 tokenId = _tokenIdCounter; // 获取当前NFT编号
        _tokenIdCounter++; // 编号自增

        _owners[tokenId] = to; // 记录NFT拥有者
        _balances[to] += 1; // 增加接收方NFT数量
        _tokenURIs[tokenId] = uri; // 存储NFT元数据链接

        emit Transfer(address(0), to, tokenId); // 触发铸造事件（从零地址转出）
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) { // 查询NFT元数据链接
        require(_owners[tokenId] != address(0), "Token doesn't exist"); // 检查NFT是否存在
        return _tokenURIs[tokenId]; // 返回元数据链接
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual { // 内部转账逻辑
        require(ownerOf(tokenId) == from, "Not owner"); // 验证转出方是拥有者
        require(to != address(0), "Zero address"); // 禁止转入零地址

        _balances[from] -= 1; // 减少转出方NFT数量
        _balances[to] += 1; // 增加转入方NFT数量
        _owners[tokenId] = to; // 更新NFT拥有者

        delete _tokenApprovals[tokenId]; // 清空NFT授权记录
        emit Transfer(from, to, tokenId); // 触发转账事件
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual { // 内部安全转账逻辑
        _transfer(from, to, tokenId); // 先执行普通转账
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver"); // 检查接收方是否支持NFT
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) { // 检查操作权限
        address owner = ownerOf(tokenId); // 获取NFT拥有者
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender)); // 验证权限
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) { // 检查NFT接收回调
        if (to.code.length > 0) { // 判断接收方是合约地址
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) { // 调用接收回调
                return retval == IERC721Receiver.onERC721Received.selector; // 验证回调返回值
            } catch { // 调用失败则返回false
                return false;
            }
        }
        return true; // 非合约地址直接返回成功
    }
}