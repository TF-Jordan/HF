package com.bbc.cairtech.record.notificationRecord;

public record NotificationRecord(String type, String message, String recipient, String priority, String channel) {}
