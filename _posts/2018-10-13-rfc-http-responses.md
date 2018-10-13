---
layout: post
title: "RFC HTTP API Feedback Proposal"
description: "RFC for implementing API HTTP responses in 6xx codes area"
category: fun
tags:
  - tricks
  - tools
---

> Internet Engineering Task Force (IETF)                     M. Skin, Ed.
> Request for Comments: 13102018                              AmotionCity
> Obsoletes: —                                               M. Skin, Ed.
> Updates: 7231                                                     Adobe
> Category: Standards Track                                  October 2018
> ISSN: 1973-3009

## HTTP/1.1: Addendum for API Feedback Codes

### Abstract

   The Hypertext Transfer Protocol API Responses are a part of modern stateless Route3 communication between HTTP server and API consumers for distributed, collaborative, hypertext information systems.
   
   This document defines the semantics of HTTP/1.1 API responses as expressed by response header fields, and response status codes, along with the payload of messages (metadata and body content) and mechanisms for content negotiation.

### Status of This Memo

   This is an Internet Standards Track document.

   This document is a product of the Internet Engineering Task Force
   (IETF).  It represents the consensus of the IETF community.  It has
   received public review and has been approved for publication by the
   Internet Engineering Steering Group (IESG).  Further information on
   Internet Standards is available in Section 2 of RFC 5741.

   Information about the current status of this document, any errata,
   and how to provide feedback on it may be obtained at
   http://www.rfc-editor.org/info.

### Proposal for New API Response Codes

[...]

---

### 6xx Consumer feedback
The consumer succeeded to process a request and wants to share their opinion.

Response feedback codes beginning with the digit **"6"** indicate cases in which the consumer is aware that it has successfully received and processed the API response and feels a necessity to provide the server with the feedback. Except when processing a 5×× response, the consumer should include an entity containing an explanation of the feedback conditions, and indicate whether it is a temporary or permanent impression. Likewise, servers should display any included entity to the development and/or marketing team. These feedback codes are applicable to any API server response.

#### **`600 OK`**

Standard feedback for successful API response. The actual response will depend on the mood of the API at the moment. In a 2×× response, the feedback will contain an impression created during response processing. In a 4××/5×× response, the feedback will contain an entity describing or containing the result of the action, the words of dissatisfaction and optionally the of level of API disappointment.

#### **`601 Considered`**

The response has been accepted for processing, but the processing has not been completed. The response might or might not be eventually acted upon, and may be completely forgotten in a matter of minutes.

#### **`602 Confused`**

The response contained an unexpected content. The response might or might not be eventually liked/disliked, and may be completely unrelated to the actual request API sent.

#### **`603 None of your business`**

The response was valid, but the API is refusing to share the impression back to the server. The server might not have the necessary reputation for an API, or may be banned/blocked of some sort.

#### **`604 Not sure`**

The response was valid, but the API is hesitating to tell whether is was good or not. The server might re-send the same response later when API will be in the mood.

#### **`605 Delighted`**

The response was lovely. The API heartfully appreciates the response.

#### **`606 Not acceptable`**

The response was harmful/abusive. The incident will be reported.

#### **`608 Retweeted`**

The response contained a valuable and/or interesting content that was shared by API with all the API subscribers. The response might or might not be eventually considered, but API just felt a necessity to broadcast it to public API channel.

---

Please consider commenting / voting this RFC for the above to happen sooner.