package com.bbc.cairtech.record.publicationRecord;

import java.time.LocalDateTime;

public record PublicationRecord(String reference, String type, String title, String content, String author, String status, String recipient, String category) {}
