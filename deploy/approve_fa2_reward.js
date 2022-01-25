"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var signer_1 = require("@taquito/signer");
var taquito_1 = require("@taquito/taquito");
var dotenv = __importStar(require("dotenv"));
dotenv.config(({ path: __dirname + '/.env' }));
var rpc = process.env.RPC; //"http://127.0.0.1:8732" //"https://hangzhounet.api.tez.ie/" //"https://127.0.0.1:8732" //"https://rpc.tzkt.io/granadanet/" //"https://granadanet.smartpy.io/"
var pk = "edskRuatoqjfYJ2iY6cMKtYakCECcL537iM7U21Mz4ieW3J51L9AZcHaxziWPZSEq4A8hu5e5eJzvzTY1SdwKNF8Pkpg5M6Xev";
var Tezos = new taquito_1.TezosToolkit(rpc);
var signer = new signer_1.InMemorySigner(pk);
Tezos.setProvider({ signer: signer });
var paused = false;
var ledger = new taquito_1.MichelsonMap();
var operators_init = [];
var admin = process.env.ADMIN_ADDRESS; //"tz1RyejUffjfnHzWoRp1vYyZwGnfPuHsD5F5"
var token_metadata = new taquito_1.MichelsonMap();
var reward_fa2_token_id = process.env.REWARD_TOKEN_ID;
var operator_address = process.env.FARM_ADDRESS; //"KT1MRRhLYf3A2eJiZsDkT3FL8GjTeMNSazyQ";
var reward_fa2_contract = process.env.REWARD_CONTRACT_ADDRESS; //"KT1CVLPrSkgzHhSWaaBSvWLGp2fce1iY3wnP";
function approve() {
    return __awaiter(this, void 0, void 0, function () {
        var op2, error_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    _a.trys.push([0, 4, , 5]);
                    return [4 /*yield*/, Tezos.contract.at(reward_fa2_contract)];
                case 1: return [4 /*yield*/, (_a.sent()).methods.update_operators([{ add_operator: { owner: admin, operator: operator_address, token_id: reward_fa2_token_id } }]).send()];
                case 2:
                    op2 = _a.sent();
                    console.log("Waiting for update_operators " + op2.hash + " to be confirmed...");
                    return [4 /*yield*/, op2.confirmation(3)];
                case 3:
                    _a.sent();
                    console.log('confirmed update_operators: ', op2.hash);
                    return [3 /*break*/, 5];
                case 4:
                    error_1 = _a.sent();
                    console.log(error_1);
                    return [3 /*break*/, 5];
                case 5: return [2 /*return*/];
            }
        });
    });
}
approve();
