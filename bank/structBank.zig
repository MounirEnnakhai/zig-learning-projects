const std = @import("std");

const BankAccount = struct {
    owner: []const u8,
    balance: f32,

    pub fn init(owner: []const u8, initial_balance: f32) BankAccount {
        return BankAccount{
            .owner = owner,
            .balance = initial_balance,
        };
    }

    pub fn deposit(self: *BankAccount, amount: f32) void {
        self.balance += amount;
    }

    pub fn withdraw(self: *BankAccount, withdowed_amount: f32) bool {
        if (withdowed_amount > self.balance) {
            return false;
        }
        self.balance -= withdowed_amount;
        return true;
    }

    pub fn account_info(self: BankAccount) void {
        std.debug.print("account info : {s} {d:.2}\n", .{ self.owner, self.balance });
    }
};
pub fn main() void {
    var account = BankAccount.init("mounir", 2000.0);
    account.account_info();
    account.deposit(3000.0);
    account.account_info();
    const success = account.withdraw(1000.0);
    std.debug.print("the withrawal is : {}\n", .{success});
    account.account_info();
}
